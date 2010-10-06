$:.unshift File.expand_path(File.dirname(__FILE__))

module Refinery
  module CatXmlImport

    autoload :SoapClient, 'catxmlimport/soap_client'
    autoload :Importer, 'catxmlimport/importer'

    def self.version
      %q{0.0.2}
    end
  end
end
