# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shellforce}
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chiharu Kawatake"]
  s.date = %q{2012-07-20}
  s.description = %q{A simple wrapper of Salesforce REST API, inspired by the Rest Client developed by Adam Wiggins,Blake Mizerany and Julien Kirch}
  s.email = %q{chiharu.kawatake@gmail.com}
  s.executables = ["shellforce", "shellforce_config", "shellforce_server"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/shellforce",
    "bin/shellforce_config",
    "bin/shellforce_server",
    "lib/shellforce.rb",
    "lib/shellforce/agent.rb",
    "lib/shellforce/agent.rb.backup",
    "lib/shellforce/application.rb",
    "lib/shellforce/client.rb",
    "lib/shellforce/command.rb",
    "lib/shellforce/config.rb",
    "lib/shellforce/config.ru",
    "lib/shellforce/exception.rb",
    "lib/shellforce/oauth2.rb",
    "lib/shellforce/payload.rb",
    "lib/shellforce/public/css/master.css",
    "lib/shellforce/public/css/restexplorer.css",
    "lib/shellforce/public/css/simpletree.css",
    "lib/shellforce/public/images/closed.gif",
    "lib/shellforce/public/images/error24.png",
    "lib/shellforce/public/images/list.gif",
    "lib/shellforce/public/images/open.gif",
    "lib/shellforce/public/images/wait16trans.gif",
    "lib/shellforce/public/js/jquery-1.6.4.min.js",
    "lib/shellforce/public/js/shellforce.js",
    "lib/shellforce/public/js/simpletreemenu.js",
    "lib/shellforce/rest.rb",
    "lib/shellforce/server.rb",
    "lib/shellforce/transport.rb",
    "lib/shellforce/util.rb",
    "lib/shellforce/views/index.haml",
    "spec/agent_spec.rb",
    "spec/agent_spec_helper.rb",
    "spec/client_spec.rb",
    "spec/config_spec.rb",
    "spec/oauth2_spec.rb",
    "spec/payload_spec.rb",
    "spec/rest_spec.rb",
    "spec/spec_helper.rb",
    "spec/transport_spec.rb",
    "spec/util_spec.rb"
  ]
  s.homepage = %q{http://github.com/mille-printemps/shellforce}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Simple wrapper of Salesforce REST API, inspired by Rest Client developed by Adam Wiggins,Blake Mizerany and Julien Kirch}
  s.test_files = ["spec/agent_spec.rb", "spec/agent_spec_helper.rb", "spec/client_spec.rb", "spec/config_spec.rb", "spec/oauth2_spec.rb", "spec/payload_spec.rb", "spec/rest_spec.rb", "spec/spec_helper.rb", "spec/transport_spec.rb", "spec/util_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_development_dependency(%q<rcov>, [">= 0.9.11"])
      s.add_development_dependency(%q<haml>, [">= 3.1.3"])
      s.add_development_dependency(%q<rack>, [">= 1.3.4"])
      s.add_development_dependency(%q<sinatra>, [">= 1.3.1"])
      s.add_development_dependency(%q<webmock>, [">= 1.7.4"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_development_dependency(%q<rack>, [">= 1.3.4"])
      s.add_development_dependency(%q<sinatra>, [">= 1.3.1"])
      s.add_development_dependency(%q<haml>, [">= 3.1.3"])
      s.add_development_dependency(%q<webmock>, [">= 1.7.4"])
      s.add_development_dependency(%q<rspec>, [">= 2.6"])
    else
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_dependency(%q<rcov>, [">= 0.9.11"])
      s.add_dependency(%q<haml>, [">= 3.1.3"])
      s.add_dependency(%q<rack>, [">= 1.3.4"])
      s.add_dependency(%q<sinatra>, [">= 1.3.1"])
      s.add_dependency(%q<webmock>, [">= 1.7.4"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<rack>, [">= 1.3.4"])
      s.add_dependency(%q<sinatra>, [">= 1.3.1"])
      s.add_dependency(%q<haml>, [">= 3.1.3"])
      s.add_dependency(%q<webmock>, [">= 1.7.4"])
      s.add_dependency(%q<rspec>, [">= 2.6"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
    s.add_dependency(%q<rcov>, [">= 0.9.11"])
    s.add_dependency(%q<haml>, [">= 3.1.3"])
    s.add_dependency(%q<rack>, [">= 1.3.4"])
    s.add_dependency(%q<sinatra>, [">= 1.3.1"])
    s.add_dependency(%q<webmock>, [">= 1.7.4"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<rack>, [">= 1.3.4"])
    s.add_dependency(%q<sinatra>, [">= 1.3.1"])
    s.add_dependency(%q<haml>, [">= 3.1.3"])
    s.add_dependency(%q<webmock>, [">= 1.7.4"])
    s.add_dependency(%q<rspec>, [">= 2.6"])
  end
end

