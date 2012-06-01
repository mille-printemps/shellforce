# coding : utf-8

require 'rubygems'
require 'shellforce/config'
require 'shellforce/agent'
require 'shellforce/rest'
require 'shellforce/util'
include ShellForce::Util

# Override the default configuration with the local one
begin
  local_config = File.join(ShellForce.config.home, "local_config")
  require local_config
  FileUtils.chmod 0700, ShellForce.config.home
  FileUtils.chmod 0600, local_config + '.rb'
rescue
  display 'No local_config.rb under ' + ShellForce.config.home + '. Make it and set necessary parameters. '
  exit!
end

$KCODE="UTF8" if RUBY_VERSION < "1.9"

module ShellForce
  class Client
    def initialize(args={})
      @agent = ShellForce::Agent.new(args)
      @agent.authenticate unless args[:access_token]
      response = @agent.get("/services/data")
      @current_path = JSON.parse(response.body).collect {|u| u["url"]}.sort[-1]
      @data_path = @current_path.dup
      @@apex_path = '/services/apexrest'
    end

    
    def instance_url
      @agent.instance_url
    end

    
    def organization_id
      @agent.organization_id
    end
    
    
    def token
      @agent.token
    end

    
    def issued_at
      @agent.issued_at
    end

    
    def user_name
      @agent.user_name
    end

    
    def id
      @agent.id
    end

    
    def to(type)
      case type
      when :apex
        if @current_path == ''
          @current_path = @@apex_path
        else
          @current_path.gsub!(/\/services\/data\/v\d+\.\d+/, @@apex_path)
        end
      when :data
        if @current_path == ''
          @current_path = @data_path
        else
          @current_path.gsub!(/\/services\/apexrest/, @data_path)
        end
      when :root
        @current_path = ''
      else
        "#{type} is not supported"
      end
    end

    
    def refresh
      @agent.authenticate
    end

    
    def head(resource, format=ShellForce.config.format)
      Rest.request(@current_path + resource, format) do |r, f|
        @agent.head(r, f)
      end
    end

    
    def get(resource, format=ShellForce.config.format)
      Rest.request(@current_path + resource, format) do |r, f|
        @agent.get(r, f)
      end
    end

    # e.g.
    # post '/sobjects/account', '{"name" : "test"}'
    # post '/chatter/feeds/news/me/feed-items', {"text" => "test"}
    # Note that the first data is String and the second one is hash    
    def post(resource, data, format=ShellForce.config.format)
      Rest.request(@current_path + resource, data, format) do |r, d, f|
        @agent.post(r, d, f)
      end
    end


    def put(resource, data, format=ShellForce.config.format)
      Rest.request(@current_path + resource, data, format) do |r, d, f|
        @agent.put(r, d, f)
      end
    end

    
    def delete(resource, format=ShellForce.config.format)
      Rest.request(@current_path + resource, format) do |r, f|
        @agent.delete(r, f)
      end
    end

    
    def patch(resource, data, format=ShellForce.config.format)
      Rest.request(@current_path + resource, data, format) do |r, d, f|
        @agent.patch(r, d, f)
      end
    end

    
    def query(query, format=ShellForce.config.format)
      Rest.request(query, format) do |q, f|
        @agent.query(@current_path, q, f)
      end
    end

    
    def search(query, format=ShellForce.config.format)
      Rest.request(query, format) do |q, f|
        @agent.search(@current_path, q, f)
      end
    end
    
    attr_reader :current_path
    
  end
end

ShellForce.config.use :default
