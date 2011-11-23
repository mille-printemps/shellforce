# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "shellforce"
  gem.homepage = "http://github.com/mille-printemps/shellforce"
  gem.license = "MIT"
  gem.summary = %Q{Simple wrapper of Salesforce REST API, inspired by Rest Client developed by Adam Wiggins and Julien Kirch}
  gem.description = %Q{A simple wrapper of Salesforce REST API, inspired by the Rest Client developed by Adam Wiggins and Julien Kirch}
  gem.email = "chiharu.kawatake@gmail.com"
  gem.authors = ["Chiharu Kawatake"]
  gem.files = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
  gem.test_files = FileList["{spec}/**/*"]
  gem.executables << 'shellforce'
  gem.executables << 'shellforce_config'
  gem.executables << 'shellforce_server'  
  gem.add_runtime_dependency("json", ">= 1.4.6")
  gem.add_development_dependency("rack", ">= 1.3.4")
  gem.add_development_dependency("sinatra", ">= 1.3.1")
  gem.add_development_dependency("haml", ">= 3.1.3")    
  gem.add_development_dependency("webmock", ">=1.7.4")  
  gem.add_development_dependency("rspec", ">=2.6")
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--colour --format progress']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "shellforce #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
