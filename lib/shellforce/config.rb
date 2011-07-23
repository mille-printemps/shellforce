# coding : utf-8

require 'webrick'
require 'singleton'

# Monkey patch for Hash
class Hash
  def set(hash)
    merge!(hash)
  end
end


module ShellForce
  class Configuration
    include Singleton

    def initialize
      @home = File.expand_path(ENV["HOME"] + '/.shellforce')      
      @config = {}
    end

    def [](name)
      @config[name] ||= {} unless @config.has_key?(name)
      @config[name]
    end

    def use(name)
      Configuration.instance[name].each_pair {|k ,v| self.send("#{k}=", v)}
    end

    attr_accessor :home, :client_id, :client_secret, \
    :host, :port, :document_root, :private_key, :cert, :logger, \
    :user_name, :password, :user_agent, :rack_config
  end

  def self.home
    Configuration.instance.home
  end
  
  def self.configure(name, &block)
    Configuration.instance[name].instance_exec(&block)
  end

  def self.config
    Configuration.instance
  end
end



ShellForce.configure :default do
  set :home => ShellForce.home
  set :client_id => nil
  set :client_secret => nil
  set :host => 'https://localhost'
  set :port => '3000'
  set :document_root => ShellForce.home
  set :private_key => File.join(ShellForce.home, 'server.key')
  set :cert => File.join(ShellForce.home, 'server.crt')
  set :logger => WEBrick::Log::new($stderr, WEBrick::Log::INFO)  
  set :user_name => nil
  set :password => nil
  set :user_agent => 'Mac FireFox'
  set :rack_config => File.join(File.dirname(File.expand_path(__FILE__)), 'config.ru')
end
