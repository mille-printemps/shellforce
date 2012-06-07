# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'webmock/rspec'
include WebMock::API

shared_context "agent_shared_context" do
  before do
    ShellForce.config.site = 'https://login.salesforce.com'
    ShellForce.config.client_id = 'client_id'
    ShellForce.config.client_secret = 'client_secret'
    ShellForce.config.user_name = 'user'
    ShellForce.config.password = 'password'

    @agent = ShellForce::Agent.new    

    @instance_url = 'https://na1.salesforce.com'
    @organization_id = 'organization_id'
    @user_id = 'user_id'
    @issued_at = '123456789'
    @signature = 'signature'
    @token = 'token'
    @refresh_token = 'refresh_token'
    @id = "https://login.salesforce.com/id/#{@organization_id}/#{@user_id}"
    @headers = {"Authorization" => "Bearer #{@token}"}
    
    @new_issued_at = '987654321'
    @new_token = 'new_token'
    @new_headers = {"Authorization" => "Bearer #{@new_token}"}

    @resource = '/resource'
    @wrong_resource = '/wrong_resource'

    @accept = {"Accept" => "application/#{ShellForce.config.format}"}
    @content_type = {"Content-Type" => "application/#{ShellForce.config.format}"}
    @pp = {"X-PrettyPrint" => "1"}

    ShellForce.config.pp = true
  end

  
  def initialize
    body = <<-BODY
{"signature":"#{@signature}","uid":null,"instance_url":"#{@instance_url}",\
"access_token":"#{@organization_id}!#{@token}","issued_at":"#{@issued_at}"}
BODY
    
    query = {
      'grant_type' => 'password',
      'client_id' => ShellForce.config.client_id,
      'client_secret' => ShellForce.config.client_secret,
      'username' => ShellForce.config.user_name,
      'password' => ShellForce.config.password
    }
    
    stub_request(:post, ShellForce.config.site + '/services/oauth2/token').
      with(:query => query).
      to_return(:body => body)
  end
  
  
  def authenticate
    initialize
    
    @agent.authenticate

    @agent.instance_url.should == @instance_url
    @agent.issued_at.should == @issued_at
    @agent.organization_id.should == @organization_id
    @agent.token.should == @token
    @agent.headers.should == @headers
  end

  
  def check(method, additional_param, additional_header, additional_resource)
    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!(@pp) if ShellForce.config.pp == true
    headers.merge!(additional_header)
    
    stub_request(method, @instance_url + @resource + additional_resource).
      with(additional_param.merge(:headers => headers)).to_return(:body => body)

    response = yield
    response.body.should == body
  end

  
  def check_with_nothing(method, additional_header={}, additional_resource='')
    check(method, {}, additional_header, additional_resource) do
      yield
    end
  end
  
  
  def check_with_query(method, payload, additional_header={}, additional_resource='')
    check(method, {:query => payload}, additional_header, additional_resource) do
      yield
    end
  end


  def check_with_string(method, payload, additional_header={}, additional_resource='')
    check(method, {:body => payload}, additional_header, additional_resource) do
      yield
    end
  end
  
end
