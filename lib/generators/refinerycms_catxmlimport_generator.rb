require 'rails/generators/migration'

class RefinerycmsCatxmlimportGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../refinerycms_catxmlimport/templates/', __FILE__)
  argument :name, :type => :string, :default => 'cat_xml_imports', :banner => ''

  def generate
    next_migration_number = ActiveRecord::Generators::Base.next_migration_number(File.dirname(__FILE__))
    template('db/migrate/migration.rb',
             Rails.root.join("db/migrate/#{next_migration_number}_create_cat_xml_import_structure.rb"))

     puts "------------------------"
     puts "Now run:"
     puts "rake db:migrate"
     puts "------------------------"
  end
end

# Below is a hack until this issue:
# https://rails.lighthouseapp.com/projects/8994/tickets/3820-make-railsgeneratorsmigrationnext_migration_number-method-a-class-method-so-it-possible-to-use-it-in-custom-generators
# is fixed on the Rails project.

require 'rails/generators/named_base'
require 'rails/generators/migration'
require 'rails/generators/active_model'
require 'active_record'

module ActiveRecord
  module Generators
    class Base < Rails::Generators::NamedBase #:nodoc:
      include Rails::Generators::Migration

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end
    end
  end
end
