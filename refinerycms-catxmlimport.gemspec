Gem::Specification.new do |s|
  s.name              = %q{refinerycms-catxmlimport}
  s.version           = %q{0.0.3}
  s.description       = %q{A RefineryCMS plugin that pulls in Cat product info for a dealership.}
  s.date              = %q{2010-10-18}
  s.summary           = %q{Ruby on Rails map engine for RefineryCMS.}
  s.email             = %q{lab@envylabs.com}
  s.homepage          = %q{http://github.com/envylabs/refinerycms-catxmlimport}
  s.authors           = %w(Envy\ Labs)
  s.require_paths     = %w(lib)

  s.files             = [
    'app',
    'app/controllers',
    'app/controllers/admin',
    'app/controllers/admin/cat_xml_imports_controller.rb',
    'app/models',
    'app/models/cat_dealership.rb',
    'app/models/cat_image.rb',
    'app/models/product.rb',
    'app/models/product_group.rb',
    'app/models/sales_feature.rb',
    'app/models/tech_spec.rb',
    'app/models/tech_spec_group.rb',
    'app/models/tech_spec_value.rb',
    'app/views',
    'app/views/admin',
    'app/views/admin/cat_xml_imports',
    'app/views/admin/cat_xml_imports/_form.html.erb',
    'app/views/admin/cat_xml_imports/edit.html.erb',
    'app/views/admin/cat_xml_imports/show.html.erb',
    'config',
    'config/locales',
    'config/locales/en.yml',
    'config/routes.rb',
    'lib',
    'lib/catxmlimport',
    'lib/catxmlimport/importer.rb',
    'lib/catxmlimport/soap_client.rb',
    'lib/catxmlimport.rb',
    'lib/gemspec.rb',
    'lib/generators',
    'lib/generators/refinerycms_catxmlimport',
    'lib/generators/refinerycms_catxmlimport/templates',
    'lib/generators/refinerycms_catxmlimport/templates/db',
    'lib/generators/refinerycms_catxmlimport/templates/db/migrate',
    'lib/generators/refinerycms_catxmlimport/templates/db/migrate/migration.rb',
    'lib/generators/refinerycms_catxmlimport/templates/lib',
    'lib/generators/refinerycms_catxmlimport/templates/lib/tasks',
    'lib/generators/refinerycms_catxmlimport/templates/lib/tasks/cat_xml_import.rake',
    'lib/generators/refinerycms_catxmlimport_generator.rb',
    'lib/refinerycms-catxmlimport.rb',
    'readme.md',
    'test',
    'test/unit',
    'test/unit/product_test.rb'
  ]
  s.test_files     = [
    'test/unit/product_test.rb'
  ]

  s.add_dependency('savon', '~> 0.7.9')
  s.add_dependency('acts_as_tree', '~> 0.1.1')
  s.add_dependency('acts_as_list', '~> 0.1.2')
end
