require 'refinery'
require File.expand_path('../catxmlimport', __FILE__)

module Refinery
  module CatXmlImport

    class Engine < Rails::Engine
      config.after_initialize do
        RefinerySetting.find_or_set(:dealership_sales_channel, 'default')
        
        Refinery::Plugin.register do |plugin|
          plugin.name = "catxmlimport"
          plugin.menu_match = /(admin|refinery)\/cat_xml_imports$/
          plugin.url = {:controller => '/admin/cat_xml_imports', :action => 'show'}
          plugin.activity = {
            :class => CatDealership,
            :title => 'sales_channel',
            :url_prefix => 'edit'
          }
        end
      end
    end

  end
end
