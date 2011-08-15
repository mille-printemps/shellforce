# coding : utf-8

require 'rubygems'
require 'shellforce/config'
require 'shellforce/server'
require 'shellforce/agent'
require 'shellforce/rest'

# Override the default configuration with the local one
begin
  local_config = File.join(ShellForce.config.home, "local_config")
  require local_config
  FileUtils.chmod 0700, ShellForce.config.home
  FileUtils.chmod 0600, local_config + '.rb'
rescue
  puts 'No local_config.rb under ' + ShellForce.config.home + '. Make it and set necessary parameters. '
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
      @version = JSON.parse(@agent.get("/services/data")).collect {|v| v["url"]}.sort[-1]
    end

    def instance_url
      @agent.instance_url
    end
    
    def token
      @agent.token
    end

    # SIGINT has to be used to kill WEBrick
    def shutdown
      Process.kill("SIGINT", @pid)
      pid, status = Process.wait2
      puts "Process #{pid} terminated."
    end

    def get(resource, format=ShellForce.config.format)
      Rest.request(@version + resource, format) do |r, f|
        @agent.get(r, f)
      end
    end

    # e.g.
    # post '/sobjects/account', '{"name" : "test"}'
    # post '/chatter/feeds/news/me/feed-items', {"text" => "test"}
    # Note that the first data is String and the second one is hash    
    def post(resource, data, format=ShellForce.config.format)
      Rest.request(@version + resource, data, format) do |r, d, f|
        @agent.post(r, d, f)
      end
    end

    def delete(resource, format=ShellForce.config.format)
      Rest.request(@version + resource, format) do |r, f|
        @agent.delete(r, f)
      end
    end

    def patch(resource, data, format=ShellForce.config.format)
      Rest.request(@version + resource, data, format) do |r, d, f|
        @agent.patch(r, d, f)
      end
    end

    def query(query, format=ShellForce.config.format)
      Rest.request(query, format) do |q, f|
        @agent.query(@version, q, f)
      end
    end

    def search(query, format=ShellForce.config.format)
      Rest.request(query, format) do |q, f|
        @agent.search(@version, q, f)
      end
    end

    attr_reader :pid, :version
    
  end
end

ShellForce.config.use :default
