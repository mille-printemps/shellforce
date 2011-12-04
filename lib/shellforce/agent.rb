# coding: utf-8

require 'rubygems'
require 'json'
require 'shellforce/transport'
require 'shellforce/config'
require 'shellforce/exception'
require 'shellforce/util'

module ShellForce
  class Agent
    def initialize(args={})
      args.merge!({:ca_file => ShellForce.config.ca_file, :verify_callback => ShellForce.config.verify_callback}) unless args[:ca_file]
      @transport = ShellForce::Transport.new(args)

      @id = args[:id]
      @instance_url = args[:instance_url]
      @issued_at = args[:issued_at]
      @signature = args[:signature]
      @refresh_token = args[:refresh_token]
      @organization_id, @token = (args[:access_token] ? args[:access_token].split('!') : [nil, nil])
      @headers = (@token ? {"Authorization" => "OAuth #{@token}"} : {})
            
      @@pp = {'X-PrettyPrint' => '1'}

      if ShellForce.config.logging
        require 'logger'
        @transport.log = Logger.new(File.join(ShellForce.home, 'log.txt'))
        @transport.log.level = Logger::DEBUG
      end
    end

    # username and password flow    
    def authenticate(user_name=ShellForce.config.user_name, password=ShellForce.config.password)
      if user_name == nil || password == nil
        user_name, password = ask_for_credentials
      end

      query = {
        'grant_type' => 'password',
        'client_id' => ShellForce.config.client_id,
        'client_secret' => ShellForce.config.client_secret,
        'username' => user_name,
        'password' => password
      }

      response = request do
        @transport.post(ShellForce.config.site + '/services/oauth2/token', query)
      end

      attributes = JSON.parse(response.body)      
      @user_name = user_name
      @instance_url = attributes['instance_url']
      @issued_at = attributes['issued_at']
      @signature = attributes['signature']
      @organization_id, @token = attributes['access_token'].split("!")      
      @headers = {"Authorization" => "OAuth #{@token}"}

      @token
    end

    
    def refresh
      query = {
        'grant_type' => 'refresh_token',
        'client_id' => ShellForce.config.client_id,
        'client_secret' => ShellForce.config.client_secret,
        'refresh_token' => @refresh_token
      }
      
      response = request do
        @transport.post(ShellForce.config.site + '/services/oauth2/token', query)
      end
      
      attributes = JSON.parse(response.body)
      @issued_at = attributes['issued_at']
      @signature = attributes['signature']
      @organization_id, @token = attributes['access_token'].split("!")
      @headers = {"Authorization" => "OAuth #{@token}"}
      
      @token
    end

    
    def head(resource, format=ShellForce.config.format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        @transport.head(@instance_url + resource, ppify(headers))
      end
    end

    
    def get(resource, format=ShellForce.config.format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        @transport.get(@instance_url + resource, '', ppify(headers))
      end
    end

    
    def post(resource, data, format=ShellForce.config.format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        if data.is_a?(String)
          headers.merge!(set_format("Content-Type", format))
        elsif data.is_a?(Hash)
          headers.merge!(set_format("Content-Type", "x-www-form-urlencoded"))
        else
          raise ArgumentError.new("data must be a string or a hash")
        end
        @transport.post(@instance_url + resource, data, ppify(headers))
      end
    end

    
    def delete(resource, format=ShellForce.config.format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        @transport.delete(@instance_url + resource, ppify(headers))
      end
    end

    
    def patch(resource, data, format=ShellForce.config.format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        headers.merge!(set_format("Content-Type", format))
        @transport.patch(@instance_url + resource, data, ppify(headers))
      end
    end

    
    def query(resource, query, format=ShellForce.config.format)
      submit_query(resource + '/query', query, format)
    end

    
    def search(resource, query, format=ShellForce.config.format)
      submit_query(resource + '/search', query, format)
    end
    
    attr_reader :id, :instance_url, :issued_at, :organization_id, :token, :headers, :user_name

    
    private

    def request
      response = yield
      response_result = Net::HTTPResponse::CODE_TO_OBJ[response.code.to_s]

      return response if response_result <= Net::HTTPSuccess
      
      if response_result <= Net::HTTPUnauthorized
        if @refresh_token
          refresh
        elsif
          authenticate
        end

        return request do
          yield
        end
      end
      raise ShellForce::ResponseCodeError.new(response.code)
    end

    
    def ppify(headers)
      ShellForce.config.pp == true ? headers.merge!(@@pp) : headers
    end

    
    def submit_query(resource, query, format)
      request do
        headers = @headers.merge(set_format("Accept", format))
        @transport.get(@instance_url + resource, {'q' => query}, ppify(headers))
      end
    end
    
    
    def set_format(header, format)
      if (format.to_s != "json") && (format.to_s != "xml") && (format.to_s != "x-www-form-urlencoded")
        raise ArgumentError.new("#{format} format is not accepted.")
      end
      {header => "application/#{format}"}
    end
    
  end
end
