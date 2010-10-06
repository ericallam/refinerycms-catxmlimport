namespace :cat_xml_import do

  desc 'Update the product catalog from the Cat XML feeds'
  task :update => :environment do
    if cat_dealership = CatDealership.first
      Refinery::CatXmlImport::Importer.new(cat_dealership.sales_channel).update
    end
  end

end
