require 'refinery'
require File.expand_path('../catxmlimport', __FILE__)

module Refinery
  module CatXmlImport

    class Engine < Rails::Engine
      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.name = "catxmlimport"
          plugin.menu_match = /(admin|refinery)\/cat_xml_import?$/
          plugin.url = {:controller => '/admin/cat_xml_import', :action => 'index'}
          plugin.activity = {
            :class => CatXmlImport,
            :title => 'title',
            :url_prefix => 'edit'
          }
        end
      end
    end

  end
end
