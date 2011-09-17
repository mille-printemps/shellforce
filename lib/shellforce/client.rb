# coding : utf-8

require 'rubygems'
require 'shellforce/config'
require 'shellforce/server'
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


$KCODE="UTF8"

module ShellForce
  class Client
    def initialize(config = ShellForce.config.rack_config)
      @agent = ShellForce::Agent.new
      @server = ShellForce::Server.new(config)

      status = begin
                 @agent.ping.size
               rescue
                 fork do
                   #ShellForce::Server.new(config).start
                   @server.start
                 end
               end

      unless status == 0
        @pid = status
        sleep 2
      end

      @agent.authenticate
      @version = JSON.parse(@agent.get("/services/data")).collect {|v| v["url"]}.sort[-1]
    end

    def instance_url
      @agent.instance_url
    end
    
    def token
      @agent.token
    end

    def issued_at
      @agent.issued_at
    end

    def refresh
      @agent.refresh
    end

    def shutdown
      begin
        n = Process.kill("SIGKILL", @pid)
        if n == 1
          display "Process #{pid} terminated."
        else
          display "Process #{pid} NOT terminated."
        end
      rescue AugmentError
        raise $!
      end
    end

    def get(resource)
      Rest.request(@version + resource) do |r|
        @agent.get(r, ShellForce.config.format)
      end
    end

    # e.g.
    # post '/sobjects/account', '{"name" : "test"}'
    # post '/chatter/feeds/news/me/feed-items', {"text" => "test"}
    # Note that the first data is String and the second one is hash    
    def post(resource, data)
      Rest.request(@version + resource, data) do |r, d|
        @agent.post(r, d, ShellForce.config.format)
      end
    end

    def delete(resource)
      Rest.request(@version + resource) do |r|
        @agent.delete(r, ShellForce.config.format)
      end
    end

    def patch(resource, data)
      Rest.request(@version + resource, data) do |r, d|
        @agent.patch(r, d, ShellForce.config.format)
      end
    end

    def query(query)
      Rest.request(query) do |q|
        @agent.query(@version, q, ShellForce.config.format)
      end
    end

    def search(query)
      Rest.request(query, format) do |q|
        @agent.search(@version, q, ShellForce.config.format)
      end
    end

    attr_reader :pid, :version
    
  end
end

ShellForce.config.use :default
