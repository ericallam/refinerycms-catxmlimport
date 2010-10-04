# Refinery CMS Cat XML Import Plugin

## About

__This plugin adds tables and rake task to import data from Cat's SOAP web service.__

Key features:

* Admin interface for configuring dealership information.
* Rake task to import data, will probably want to add this as a cron job.

## How do I use it?

To install the cat xml import plugin, you can either include the gem or install as a plugin.

## Requirements

[RefineryCMS](http://refinerycms.com) version 0.9.7 or later.

### Gem Installation using Bundler

Include the latest [gem](http://rubygems.org/gems/refinerycms-map) into your Refinery CMS application's Gemfile:

    gem "refinerycms-catxmlimport", '~> 0.0.1', :require => "catxmlimport"

Then type the following at command line inside your Refinery CMS application's root directory:

    bundle install
    script/generate catxmlimport
    rake db:migrate

### Rails Engine Installation

If you do not want to install the engine via bundler then you can install it as an engine inside your application's vendor directory.
Type the following at command line inside your Refinery CMS application's root directory:

    script/plugin install git://github.com/envylabs/refinerycms-catxmlimport.git
    script/generate catxmlimport
    rake db:migrate
