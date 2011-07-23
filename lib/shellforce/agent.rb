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
      RESPONSE_HAS_BODY = false
    end
  end
end


module ShellForce
  class Agent
    def initialize
      @host = [ShellForce.config.host, ShellForce.config.port].join(':')
      @agent = Mechanize.new
      @agent.user_agent_alias = ShellForce.config.user_agent
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
      
      @instance_url = attributes['instance_url']
      @organization_id, @token = attributes['credentials']['token'].split("!")
      @headers = {"Authorization" => "OAuth #{@token}"}
    end

    def head(resource, data={}, type=:json)
      @agent.head(@instance_url + resource, data,
                  :headers => @headers.merge(format("Accept", type)))
      @agent.page.body
    end

    def get(resource, type=:json)
      @agent.get(:url => @instance_url + resource,
                 :headers => @headers.merge(format("Accept", type)))
      @agent.page.body
    end

    def post(resource, data, type=:json)
      headers = @headers.merge(format("Accept", type))
      headers.merge!(format("Content-Type", type))
      
      if data.is_a?(String)
        @agent.post(@instance_url + resource, data, headers)
      else
        query = if data.is_a?(Hash)
                  data.collect {|k,v| "#{k}=#{url_escape(v)}"}
                elsif data.is_a?(Array)
                  data.collect {|v| "#{v[0]}=#{url_escape(v[1])}"}
                else
                  raise ArguementError.new('The query must be a hash or an array of an array.')
                end
        @agent.post(@instance_url + resource + "?#{query.join('&')}", '', headers)
      end

      @agent.page.body
    end
    
    def delete(resource, type=:json)
      @agent.delete(@instance_url + resource, {},
                    :headers => @headers.merge(format("Accept", type)))
      @agent.page.body
    end
    
    def patch(resource, data, type=:json)
      headers = @headers.merge(format("Accept", type))
      headers.merge!(format("Content-Type", type))
      
      @agent.request_with_entity(:patch, @instance_url + resource, data, :headers => headers)
      @agent.page.body
    end

    def query(resource, query, type=:json)
      submit_query(resource + '/query', query, type)
    end

    def search(resource, query, type=:json)
      submit_query(resource + '/search', query, type)
    end
    
    attr_reader :host, :instance_url, :organization_id, :token, :headers
    
    private

    # Salesforce does redirects by JavaScript.
    # I admit that the following code is hacky.
    def redirect
      @agent.page.root.search('script').children.find{|c| c.text =~ /var url = '(.+)'/}
      $1 == nil ? nil : @agent.get($1)
    end

    def submit_query(resource, query, type)
      @agent.get(:url => @instance_url + resource, :params => {'q' => query},
                 :headers => @headers.merge(format("Accept", type)))
      @agent.page.body
    end

    def url_escape(text)    
      CGI.escape(Mechanize::Util.html_unescape(text))
    end

    def format(header, type)
      format = type.to_s
      if (format != "json") && (format != "xml")
        raise ArgumentError.new("#{format} format is not accepted.")
      end
        
      {header => "application/#{format}"}
    end
    
  end
end
