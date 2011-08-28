# coding: utf-8

require 'rubygems'
require 'net/http'
require 'mechanize'
require 'json'
require 'omniauth'
require 'shellforce/config'


# Monkey patch for 'PATCH' method
module Net
  class HTTP
    class Patch < Net::HTTPRequest
      METHOD = 'PATCH'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end
  end
end

module ShellForce
  class Agent
    def initialize
      @host = [ShellForce.config.host, ShellForce.config.port].join(':')
      @agent = Mechanize.new
      @agent.user_agent_alias = ShellForce.config.user_agent

      if ShellForce.config.logging
        require 'logger'
        Mechanize.log = Logger.new(File.join(ShellForce.home, 'log.txt'))
        Mechanize.log.level = Logger::DEBUG
      end
      
    end

    def ping
      @agent.get(@host)
      JSON.parse(@agent.page.body)      
    end
    
    def authenticate
      @agent.get(@host + OmniAuth.config.path_prefix + '/forcedotcom')

      login_form = redirect.form_with('login')
      if login_form != nil
        login_form.username = ShellForce.config.user_name
        login_form.pw = ShellForce.config.password
        login_form.un = ShellForce.config.user_name
        login_form.submit

        redirect
        redirect
      end

      attributes = JSON.parse(@agent.page.root.search('p').children.text)
      # TODO : conversion of "issued_at"
      @instance_url = attributes['instance_url']
      @issued_at = attributes['issued_at']
      @refresh_token = attributes['refresh_token']
      @signature = attributes['signature']
      @organization_id, @token = attributes['credentials']['token'].split("!")
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
      
      @agent.post(ShellForce.config.site + '/services/oauth2/token',
                  query,
                  set_format("Accept", :json))
      
      attributes = JSON.parse(@agent.page.body)
      
      @issued_at = attributes['issued_at']
      @signature = attributes['signature']
      @organization_id, @token = attributes['access_token'].split("!")
      @headers = {"Authorization" => "OAuth #{@token}"}
      
      @token
    end

    def head(resource, data={}, format=ShellForce.config.format)
      @agent.head(@instance_url + resource, data,
                  :headers => @headers.merge(set_format("Accept", format)))
      @agent.page.body
    end

    def get(resource, format=ShellForce.config.format)
      @agent.get(:url => @instance_url + resource,
                 :headers => @headers.merge(set_format("Accept", format)))
      @agent.page.body
    end

    def post(resource, data, format=ShellForce.config.format)
      headers = @headers.merge(set_format("Accept", format))
      headers.merge!(set_format("Content-Type", format))
      
      if data.is_a?(String)
        @agent.post(@instance_url + resource, data, headers)
      else
        query = if data.is_a?(Hash)
                  data.collect {|k,v| "#{k}=#{escape_url(v)}"}
                elsif data.is_a?(Array)
                  data.collect {|v| "#{v[0]}=#{escape_url(v[1])}"}
                else
                  raise ArguementError.new('The query must be a hash or an array of an array.')
                end
        @agent.post(@instance_url + resource + "?#{query.join('&')}", '', headers)
      end

      @agent.page.body
    end
    
    def delete(resource, format=ShellForce.config.format)
      @agent.delete(@instance_url + resource, {},
                    :headers => @headers.merge(set_format("Accept", format)))
      @agent.page.body
    end
    
    def patch(resource, data, format=ShellForce.config.format)
      headers = @headers.merge(set_format("Accept", format))
      headers.merge!(set_format("Content-Type", format))
      
      @agent.request_with_entity(:patch, @instance_url + resource, data, :headers => headers)
      @agent.page.body
    end

    def query(resource, query, format=ShellForce.config.format)
      submit_query(resource + '/query', query, format)
    end

    def search(resource, query, format=ShellForce.config.format)
      submit_query(resource + '/search', query, format)
    end
    
    attr_reader :host, :instance_url, :issued_at, :organization_id, :token, :headers
    
    private

    # Salesforce redirects from one URL to another URL using JavaScript.
    # I admit that the following code is hacky.
    def redirect
      @agent.page.root.search('script').children.find{|c| c.text =~ /var url = '(.+)'/}
      $1 == nil ? nil : @agent.get($1)
    end

    def submit_query(resource, query, format)
      @agent.get(:url => @instance_url + resource, :params => {'q' => query},
                 :headers => @headers.merge(set_format("Accept", format)))
      @agent.page.body
    end

    def escape_url(text)    
      CGI.escape(Mechanize::Util.html_unescape(text))
    end

    def set_format(header, format)
      if (format.to_s != "json") && (format.to_s != "xml")
        raise ArgumentError.new("#{format} format is not accepted.")
      end

      {header => "application/#{format}"}
    end
    
  end
end
