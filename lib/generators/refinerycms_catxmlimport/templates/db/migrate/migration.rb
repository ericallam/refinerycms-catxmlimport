class CreateCatXmlImportStructure < ActiveRecord::Migration

  def self.up

    create_table "cat_dealerships", :force => true do |t|
      t.string   "sales_channel"
    end

    add_index :cat_dealerships, :id

    create_table "cat_images", :force => true do |t|
      t.string   "url"
      t.string   "image_type"
      t.string   "cat_id"
      t.string   "imagable_type"
      t.integer  "imagable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "thumbnail_file_name"
      t.string   "thumbnail_content_type"
      t.integer  "thumbnail_file_size"
      t.datetime "thumbnail_updated_at"
      t.string   "document_content_type"
      t.string   "document_file_name"
      t.integer  "document_file_size"
      t.datetime "document_updated_at"
    end

    add_index :cat_images, :id

    create_table "product_groups", :force => true do |t|
      t.string   "name"
      t.string   "footnote"
      t.integer  "cat_id"
      t.integer  "parent_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "application_category_id"
    end

    add_index :product_groups, :id

    create_table "products", :force => true do |t|
      t.string   "name"
      t.string   "long_name"
      t.string   "brand"
      t.integer  "cat_id"
      t.string   "non_display_name"
      t.integer  "product_group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "dealership_id"
      t.boolean  "seed",             :default => false
    end

    add_index :products, :id

    create_table "related_products", :id => false, :force => true do |t|
      t.integer "product_id"
      t.integer "related_product_id"
    end

    add_index :related_products, [:product_id, :related_product_id]

    create_table "sales_features", :force => true do |t|
      t.integer  "cat_id"
      t.string   "name"
      t.text     "paragraph"
      t.integer  "featurable_id"
      t.string   "featurable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :sales_features, :id

    create_table "tech_spec_groups", :force => true do |t|
      t.integer  "product_group_id"
      t.integer  "cat_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :tech_spec_groups, :id

    create_table "tech_spec_values", :force => true do |t|
      t.integer  "cat_id"
      t.decimal  "english_value", :precision => 12, :scale => 4
      t.decimal  "metric_value",  :precision => 12, :scale => 4
      t.string   "text_value"
      t.integer  "product_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :tech_spec_values, :id

    create_table "tech_specs", :force => true do |t|
      t.integer  "tech_spec_group_id"
      t.integer  "cat_id"
      t.string   "name"
      t.string   "type"
      t.integer  "position"
      t.string   "english_unit"
      t.string   "metric_unit"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :tech_specs, :id

    User.find(:all).each do |user|
      user.plugins.create(:name => "catxmlimport", :position => (user.plugins.maximum(:position) || -1) +1)
    end

  end

  def self.down
    UserPlugin.destroy_all({:name => "catxmlimport"})

    Page.destroy_all({:link_url => "/cat_xml_import"})

    drop_table :cat_images
    drop_table :cat_dealerships
    drop_table :product_groups
    drop_table :products
    drop_table :related_products
    drop_table :sales_features
    drop_table :tech_spec_groups
    drop_table :tech_spec_values
    drop_table :tech_specs
  end

end
