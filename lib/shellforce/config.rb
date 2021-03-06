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

    
    def copy(from, to)
      Configuration.instance[from].each_pair{|k, v|
        Configuration.instance[to][k] = (v != nil && (v.is_a?(String) || v.is_a?(Array) || v.is_a?(Hash))) ? v.dup : v
      }
    end
    

    attr_accessor :host, :port, :document_root, :private_key, :cert, \
    :server_logger, :server_access_logger, :ca_file, :verify_callback, \
    :path, :auth_path, :rack_config, \
    :home, :site, :client_id, :client_secret, \
    :user_name, :password, :user_agent, :format, :pp, :logging, \
    :preprocess, :postprocess
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
  # WEBrick configuration
  set :host => 'https://localhost'  
  set :port => 3000
  set :document_root => ShellForce.home
  set :private_key => File.join(ShellForce.home, 'key.pem')
  set :cert => File.join(ShellForce.home, 'cert.pem')
  set :server_logger => WEBrick::Log::new($stderr, WEBrick::Log::FATAL)  
  set :server_access_logger => []
  set :ca_file => nil
  set :verify_callback => lambda{|success, context|
    if (!success) || context.error != 0
      raise SecurityError.new("SSL verification failed - #{success}, #{context.error} : #{context.error_string}")
    end
    true
  }
  
  # OAuth2 configuration
  set :path => '/shellforce'
  set :auth_path => '/shellforce/auth'
  set :rack_config => File.join(File.dirname(File.expand_path(__FILE__)), 'config.ru')
  
  # ShellForce configuration  
  set :home => ShellForce.home
  set :site => 'https://login.salesforce.com'
  set :client_id => nil
  set :client_secret => nil
  set :user_name => nil
  set :password => nil
  set :user_agent => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6'
  set :format => :json
  set :pp => true
  set :logging => false
  set :preprocess => [lambda{|*args| return args}]
  set :postprocess => [lambda{|headers, body| return headers, body}]
end
