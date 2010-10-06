require 'logger'

module Refinery
  module CatXmlImport
    class SoapClient

      attr_reader :sales_channel, :logger, :wsdl, :language

      def initialize(sales_channel, logger = Logger.new('log/soap_client.log'), wsdl = 'http://xml.catmms.com/cmms?wsdl', language = 'en')
        @sales_channel, @logger, @wsdl, @language = sales_channel, logger, wsdl, language
      end

      def get_classes
        resp = savon_client.get_classes do |soap|
          soap.body = {
            'SalesChannelCode'  => self.sales_channel,
            'LanguageId'        => self.language
          }
        end

        resp.to_hash[:get_classes_response][:cmms][:listofgroups][:product_group]
      end

      def get_tree(id)
        tree = savon_client.get_tree do |soap|
          soap.body = {
            'SalesChannelCode'  => self.sales_channel,
            'LanguageId'        => self.language,
            'id'                => id
          }
        end

        tree.to_hash[:get_tree_response][:cmms][:product_group]
      end

      def get_group_detail(id)
        tree = savon_client.get_group_detail do |soap|
          soap.body = {
            'SalesChannelCode'  => self.sales_channel,
            'LanguageId'        => self.language,
            'id'                => id
          }
        end

        begin
          tree.to_hash[:get_group_detail_response][:cmms][:product_group]
        rescue => e
          logger.error("get_group_detail error: #{e} \n #{e.backtrace.join("\n")}")
        end
      end

      def get_product_detail(group_id, id)
        tree = savon_client.get_product_detail do |soap|
          soap.body = {
            'SalesChannelCode'  => self.sales_channel,
            'LanguageId'        => self.language,
            'GroupId'           => group_id,
            'id'                => id
          }
        end

        tree.to_hash[:get_product_detail_response][:cmms][:product]
      end
      

      private


      def savon_client
        @savon_client ||= ::Savon::Client.new(self.wsdl)
      end

    end
  end
end
