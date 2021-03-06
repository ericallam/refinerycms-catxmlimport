#!/usr/bin/env ruby
require File.expand_path('../catxmlimport.rb', __FILE__)
version = ::Refinery::CatXmlImport.version
raise "Could not get version so gemspec can not be built" if version.nil?
files = Dir.glob("**/*").flatten.reject do |file|
  file =~ /\.gem(spec)?$/
end

gemspec = <<EOF
Gem::Specification.new do |s|
  s.name              = %q{refinerycms-catxmlimport}
  s.version           = %q{#{version}}
  s.description       = %q{A RefineryCMS plugin that pulls in Cat product info for a dealership.}
  s.date              = %q{#{Time.now.strftime('%Y-%m-%d')}}
  s.summary           = %q{Ruby on Rails map engine for RefineryCMS.}
  s.email             = %q{lab@envylabs.com}
  s.homepage          = %q{http://github.com/envylabs/refinerycms-catxmlimport}
  s.authors           = %w(Envy\\ Labs)
  s.require_paths     = %w(lib)

  s.files             = [
    '#{files.join("',\n    '")}'
  ]
  #{"s.test_files     = [
    '#{Dir.glob("test/**/*.rb").join("',\n    '")}'
  ]" if File.directory?("test")}

  s.add_dependency('savon', '~> 0.7.9')
  s.add_dependency('acts_as_tree', '~> 0.1.1')
  s.add_dependency('acts_as_list', '~> 0.1.2')
end
EOF

File.open(File.expand_path("../../refinerycms-catxmlimport.gemspec", __FILE__), 'w').puts(gemspec)
