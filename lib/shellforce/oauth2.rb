# coding : utf-8

require 'rubygems'
require 'rack'
require 'json'
require 'shellforce/config'
require 'shellforce/transport'

module ShellForce
  class OAuth2
    def initialize(app, options={})
      @app = app
      @options = options
      @full_path = [ShellForce.config.host, ShellForce.config.port].join(':') + ShellForce.config.path
      @transport = ShellForce::Transport.new
    end

    
    def call(env)
      @request = Rack::Request.new(env)
      
      if current_path == ShellForce.config.path
        query = {
          'response_type' => 'code',
          'client_id' => ShellForce.config.client_id,
          'redirect_uri' => @full_path + '/callback'
        }

        redirect(@transport.build_uri(ShellForce.config.site + '/services/oauth2/authorize', query.merge!(@options)))

      elsif current_path == ShellForce.config.path + '/callback'
        if @request.params['error']
          raise ShellForce::CallbackError.new(@request.params['error'], @request.params['error_description'])
        end

        query = {
          'grant_type' => 'authorization_code',
          'code' => @request.params['code'],
          'client_id' => ShellForce.config.client_id,          
          'client_secret' => ShellForce.config.client_secret,
          'redirect_uri' => @full_path + '/callback',
          'format' => 'json'
        }

        response = begin
                     @transport.post(ShellForce.config.site + '/services/oauth2/token', query)
                   rescue StandardError => e
                     raise e
                   end

        env['shellforce.oauth2'] = response.body
        @app.call(env)

      else
        @app.call(env)
      end
    end

    
    private
    
    def current_path
      @request.path_info.downcase.sub(/\/$/, '')
    end

    
    def redirect(uri)
      response = Rack::Response.new
      response.write("Redirecting to #{uri}...")
      response.redirect(uri)
      response.finish
    end
  
  end
end

