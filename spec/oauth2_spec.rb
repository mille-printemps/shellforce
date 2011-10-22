# coding : utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'cgi'
require 'stringio'
require 'webmock/rspec'
include WebMock::API

def build_env(path=ShellForce.config.path, query={}, properties={})
  query_string = query.collect{|k,v| "#{k}=#{CGI.escape(v)}"}.join('&')
  {
    "PATH_INFO" => path,
    "QUERY_STRING" => query_string,
    'rack.input' => StringIO.new,
    'rack.request.query_string' => query_string,
    'rack.request.query_hash' => query
  }.merge(properties)
end


describe ShellForce::OAuth2 do

  before do
    app = lambda{|env| return env}
    @oauth2 = ShellForce::OAuth2.new(app)

    ShellForce.config.site = 'https://login.salesforce.com'
    ShellForce.config.host = 'https://localhost'
    ShellForce.config.port = 3000
    ShellForce.config.path = '/shellforce/auth'
    ShellForce.config.client_id = 'client_id'
    ShellForce.config.client_secret = 'client_secret'
  end
  

  it "is initialized" do
    @oauth2.full_path.should == [ShellForce.config.host, ShellForce.config.port].join(':') + ShellForce.config.path
  end


  it "redirects a request" do
    query = {
      'response_type' => 'code',
      'client_id' => ShellForce.config.client_id,
      'redirect_uri' => @oauth2.full_path + '/callback'
    }

    stub_request(:get, ShellForce.config.site + '/services/oauth2/authorize').
      with(:query => query).to_return(:status => 200)

    response = @oauth2.call(build_env(ShellForce.config.path, query))
    response[0] == 200
  end


  it "sends a POST request" do
    query = {
      'grant_type' => 'authorization_code',
      'code' => 'code',
      'client_id' => ShellForce.config.client_id,
      'client_secret' => ShellForce.config.client_secret,
      'redirect_uri' => @oauth2.full_path + '/callback',
      'format' => 'json'
    }

    body = 'body'

    stub_request(:post, ShellForce.config.site + '/services/oauth2/token').
      with(:query => query).to_return(:body => body)

    response = @oauth2.call(build_env(ShellForce.config.path + '/callback', query))
    response['shellforce.oauth2'].should == body
  end

  
  it "just calls the application" do
    env = build_env('/dummy')
    response = @oauth2.call(env)
    response.should == env
  end
  

  it "raises an exception" do
    error_code = 'error'
    error_description = 'error_description'
    
    query = {
      'code' => 'code',
      'error' => error_code,
      'error_description' => error_description
    }
    
    begin
      response = @oauth2.call(build_env(ShellForce.config.path + '/callback', query))
    rescue StandardError => e
      e.error_code.should == error_code
    end
  end

  
  
end

