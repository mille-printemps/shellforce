# coding : utf-8

require 'rubygems'
require 'shellforce/config'
require 'shellforce/server'
require 'shellforce/agent'
require 'shellforce/rest'

# Override the default configuration with the local one
begin
  orgprofile = File.join(ShellForce.config.home, "orgprofile")
  require orgprofile
  FileUtils.chmod 0700, ShellForce.config.home
  FileUtils.chmod 0600, orgprofile + '.rb'
rescue
  puts 'No orgproifle.rb under ' + ShellForce.config.home + '. Make it and set necessary parameters. '
  exit!
end

$KCODE="UTF8"

module ShellForce
  class Client
    def initialize(config = ShellForce.config.rack_config)
      @agent = ShellForce::Agent.new

      status = begin
                 @agent.ping.size
               rescue
                 fork do
                   ShellForce::Server.new(config).start
                 end
               end

      unless status == 0
        @pid = status
        sleep 2
      end

      @agent.authenticate
      version = @agent.get("/services/data").collect {|v| v["url"]}.sort[-1]
      @version_url = version
    end

    def instance_url
      @agent.instance_url
    end
    
    def token
      @agent.token
    end

    def pid
      @pid
    end

    def shutdown
      Process.kill("SIGTERM", @pid)
      pid, status = Process.wait2
      puts "Process #{pid} terminated."
    end
    
    def get(resource)
      Rest.request(@version_url + resource) do |r|
        @agent.get(r)
      end
    end

    # e.g.
    # post '/sobjects/account', '{"name" : "test"}'
    # post '/chatter/feeds/news/me/feed-items', {"text" => "test"}
    # Note that the first data is String and the second one is hash    
    def post(resource, data)
      Rest.request(@version_url + resource, data) do |r, d|
        @agent.post(r, d)
      end
    end

    def delete(resource)
      Rest.request(@version_url + resource) do |r|
        @agent.delete(r)
      end
    end

    def patch(resource, data)
      Rest.request(@version_url + resource, data) do |r, d|
        @agent.patch(r, d)
      end
    end

    def query(query)
      Rest.request(query) do |q|
        @agent.query(@version_url, q)
      end
    end

    def search(query)
      Rest.request(query) do |q|
        @agent.search(@version_url, q)
      end
    end

  end
end

ShellForce.config.use :default
