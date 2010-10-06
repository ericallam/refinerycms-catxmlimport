class Admin::CatXmlImportsController < Admin::BaseController

  crudify :cat_dealership,  :redirect_to_url => 'admin_cat_xml_import_path',
                            :title_attribute => 'sales_channel'

  def find_cat_dealership
    @cat_dealership = CatDealership.first || CatDealership.new
  end
end
