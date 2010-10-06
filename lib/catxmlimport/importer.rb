require 'logger'

module Refinery
  module CatXmlImport
    class Importer

      attr_reader :client

      def initialize(sales_channel)
        @client = Refinery::CatXmlImport::SoapClient.new(sales_channel, logger)
      end

      def logger
        @logger ||= Logger.new('log/importer.log')
      end

      def update
        # ProductGroup.transaction do
        logger.info("==== Running CatXml::Importer (%s) ====" % [Time.now.to_s])
        hierarchy = fetch_hierarchy
        update_hierarchy_details(hierarchy)
        logger.info("==== Finished CatXml::Importer (%s) ====" % [Time.now.to_s])
        # end
      end

      def fetch_hierarchy
        top_level_groups = fetch_top_level_groups

        top_level_groups.each do |top_level_group|
          fetch_tree_for(top_level_group)
        end

        top_level_groups
      end

      def fetch_top_level_groups
        client.get_classes.map do |group_hash|
          group = ::ProductGroup.find_or_create_by_cat_id(
            :cat_id => group_hash[:id],
            :name => group_hash[:name],
            :parent_id => nil
          )
        end
      end

      def fetch_tree_for(top_level_group)
        client.get_tree(top_level_group.cat_id).tap do |tree|
          tree[:listofgroups][:product_group].map do |group_hash|
            update_tree_for(group_hash, top_level_group.id)
          end
        end
      end

      def update_tree_for(group_hash, parent_id)
        group = ::ProductGroup.find_or_create_by_cat_id(
          :cat_id => group_hash[:id],
          :name => group_hash[:name],
          :parent_id => parent_id
        )

        if group_hash[:listofproducts]
          # if there is only one child product node then Crack returns a Hash instead of Array
          [group_hash[:listofproducts][:product]].flatten.map { |p| update_product(p, group) }
        end

        # recursively find/create child ProductGroups
        if group_hash[:listofgroups]
          # if there is only one child product_group node then Crack returns a Hash instead of Array
          [group_hash[:listofgroups][:product_group]].flatten.each { |pg| update_tree_for(pg, group.id) }
        end

        group
      end

      def update_product(product_hash, group)
        product = group.products.find_by_cat_id(product_hash[:id])
        if product
          product.update_attribute(:non_display_name, product_hash[:nondisplayname])
        else
          product = group.products.create(:cat_id => product_hash[:id], :non_display_name => product_hash[:nondisplayname])
        end
      end

      def update_hierarchy_details(groups)
        groups.each do |group|
          update_group_details(group)
        end
      end

      def update_group_details(group)
        group_hash = client.get_group_detail(group.cat_id)

        logger.info("update_group_details for group #{group.id} with group_hash: #{group_hash.inspect}")

        if group_hash && group_hash[:name].kind_of?(String)
          group.update_attributes(
            :name     => group_hash[:name].strip,
            :footnote => group_hash[:footnote]
          )
          update_sales_features_for_parent(group_hash, group)
          update_images_for_parent(group_hash, group)
          update_tech_spec_groups(group_hash, group)
          
          logger.info("update_group_details for group #{group.id}")
          logger.info("update_group_details with #{group.products.count} products")

          products = group.products.reload

          products.each do |product|
            update_product_details(product)
          end

          logger.info("update_group_details for children: #{group.children.size} (#{group.children.map(&:id).inspect})")

          children = group.children.reload

          children.each do |sub_group|
            update_group_details(sub_group)
          end
        else
          group.destroy
        end
      end

      def update_product_details(product)
        product_hash = client.get_product_detail(product.product_group.cat_id, product.cat_id)

        name = product_hash[:name].kind_of?(String) ? product_hash[:name].strip : nil
        long_name = product_hash[:longname].kind_of?(String) ? product_hash[:longname].strip : nil

        product.update_attributes(
          :name             => name,
          :long_name        => long_name,
          :brand            => product_hash[:brand],
          :non_display_name => product_hash[:nondisplayname],
          :related_ids      => parse_related_product_ids(product_hash)
        )

        logger.info("update_product_details for product: #{product.id}")

        update_sales_features_for_parent(product_hash, product)
        update_images_for_parent(product_hash, product)
        update_tech_spec_values(product_hash, product)
      end


      private


      def update_sales_features_for_parent(parent_hash, parent)
        if parent_hash[:listofsalesfeatures]
          [parent_hash[:listofsalesfeatures][:salesfeature]].flatten.each do |sales_feature_hash|
            parent.sales_features.find_or_create_by_cat_id(
              sales_feature_hash[:id]
            ).tap { |obj| obj.update_attributes(
              :name       => sales_feature_hash[:name],
              :paragraph  => sales_feature_hash[:paragraph]
            ) }
          end
        end
      end

      def update_images_for_parent(parent_hash, parent)
        logger.info("update_images_for_parent with parent_hash: #{parent_hash.inspect}")

        if parent_hash[:listofimages]
          [parent_hash[:listofimages][:image]].flatten.each do |image_hash|
            
            logger.info("update_images_for_parent with image_hash: #{image_hash.inspect}")

            image = parent.images.find_or_create_by_cat_id(
              image_hash[:id]
            ).tap { |obj| obj.update_attributes(
              :image_type => image_hash[:type],
              :url        => image_hash[:url]
            ) }

            if image.new_record? or !image.valid?
              logger.info("Failed to create a new image, errors: #{image.errors.to_a.inspect}")
            else
              logger.info("Successfully created or updated image id #{image.id}")
            end
          end
        end
      end

      def update_tech_spec_groups(group_hash, group)
        if group_hash[:listoftechspecgroups]
          [group_hash[:listoftechspecgroups][:techspecgroup]].flatten.each do |tech_spec_group_hash|
            group.tech_spec_groups.find_or_create_by_cat_id(
              tech_spec_group_hash[:id]
            ).tap do |tsg|
              name = tech_spec_group_hash[:name].kind_of?(String) ? tech_spec_group_hash[:name].strip : nil
              tsg.update_attributes(:name => name)
              update_tech_specs(tech_spec_group_hash, tsg)
            end
          end
        end
      end

      def update_tech_specs(tech_spec_group_hash, group)
        if tech_spec_group_hash[:listoftechspecs]
          [tech_spec_group_hash[:listoftechspecs][:techspec]].flatten.each do |tech_spec_hash|
            group.tech_specs.find_or_create_by_cat_id(
              tech_spec_hash[:id]
            ).tap { |obj| obj.update_attributes(
              :name           => tech_spec_hash[:name],
              :type           => tech_spec_hash[:type],
              :position       => tech_spec_hash[:sort_sequence],
              :english_unit   => tech_spec_hash[:english_unit],
              :metric_unit    => tech_spec_hash[:metric_unit]
            ) }
          end
        end
      end

      def update_tech_spec_values(product_hash, product)
        if product_hash[:listoftechspecvalues]
          [product_hash[:listoftechspecvalues][:techspecvalue]].flatten.each do |tech_spec_value_hash|
            product.tech_spec_values.find_or_create_by_cat_id(
              tech_spec_value_hash[:id]
            ).tap { |obj| obj.update_attributes(
              :english_value  => tech_spec_value_hash[:english_value],
              :metric_value   => tech_spec_value_hash[:metric_value],
              :text_value     => tech_spec_value_hash[:text_value]
            ) }
          end
        end
      end

      def parse_related_product_ids(product_hash)
        related_cat_ids = if product_hash[:listofrelationships]
          [product_hash[:listofrelationships][:relationship]].flatten.map{ |r| r[:related_to_id] }
        else
          []
        end

        related_cat_ids.map{ |cat_id| ::Product.find_by_cat_id(cat_id).try(:id) }
      end

    end
  end
end
