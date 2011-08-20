# coding: utf-8

require 'rubygems'
require 'rack'
require 'shellforce/config'

module ShellForce
  class Server < Rack::Server
    def initialize(config = ShellForce.config.rack_config)
      super(:include => File.dirname(config), :config => config)
    end
    
    def start
      super.start
    end

    def stop
      if server.respond_to?(:shutdwon)
        server.shutdown
      else
        exit! 0
      end
    end

  end
end
