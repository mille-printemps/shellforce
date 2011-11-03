# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/agent_spec_helper')

require 'webmock/rspec'
include WebMock::API

describe ShellForce::Agent do
  include_context "agent_shared_context"

  it "can be intialized by arguments" do
    args = {"signature" => "#{@signature}", "id" => "#{@id}", "instance_url" => "#{@instance_url}",\
      "access_token" => "#{@organization_id}!#{@token}", "issued_at" => "#{@issued_at}"}
    
    agent = ShellForce::Agent.new(args)

    agent.id.should == @id
    agent.instance_url.should == @instance_url
    agent.issued_at.should == @issued_at
    agent.organization_id.should == @organization_id
    agent.token.should == @token
  end
  
  
  it "makes a log file when the log flag is set" do
    ShellForce.config.logging = true
    
    agent = ShellForce::Agent.new
    log_file = File.join(ShellForce.home, 'log.txt')
    
    File.exists?(log_file).should == true
    FileUtils.remove(log_file)
    
    ShellForce.config.logging = false
  end


  it "refreshes a token" do
    args = {
      'instance_url' => @instance_url,
      'issued_at' => @issued_at,
      'signature' => @signature,
      'access_token' => "#{@organization_id}!#{@token}",
      'refresh_token' => @refresh_token
    }
    
    agent = ShellForce::Agent.new(args)

    body = <<-BODY
{"signature":"#{@signature}","instance_url":"#{@instance_url}",\
"access_token":"#{@organization_id}!#{@new_token}","issued_at":"#{@new_issued_at}"}
BODY

    query = {
        'grant_type' => 'refresh_token',
        'client_id' => ShellForce.config.client_id,
        'client_secret' => ShellForce.config.client_secret,
        'refresh_token' => @refresh_token
    }
    
    stub_request(:post, ShellForce.config.site + '/services/oauth2/token').
      with(:query => query).to_return(:body => body)
      
    agent.refresh

    agent.issued_at.should == @new_issued_at
    agent.token.should == @new_token
    agent.headers.should  == @new_headers
  end

  
  it "sends a HEAD request" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!(@pp) if ShellForce.config.pp == true

    stub_request(:head, @instance_url + @resource).
      with(:headers => headers).to_return(:body => body)
    
    response = @agent.head(@resource)
    response.body.should == body
  end
  
  
  it "sends a GET request" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!(@pp) if ShellForce.config.pp == true
    
    stub_request(:get, @instance_url + @resource).
      with(:headers => headers).to_return(:body => body)
    
    response = @agent.get(@resource)
    response.body.should == body
  end

  
  it "sends a POST request with a string" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!(@content_type)
    headers.merge!(@pp) if ShellForce.config.pp == true
    
    request = '{"name" => "name"}'
    
    stub_request(:post, @instance_url + @resource).
      with(:body => request, :headers => headers).to_return(:body => body)

    response = @agent.post(@resource, request)
    response.body.should == body
  end

  
  it "sends a POST request with a hash" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!("Content-Type" => "application/x-www-form-urlencoded")
    headers.merge!(@pp) if ShellForce.config.pp == true
    
    query = {"a" => "b", "c" => "d"}

    stub_request(:post, @instance_url + @resource).
      with(:query => query, :headers => headers).to_return(:body => body)

    response = @agent.post(@resource, query)
    response.body.should == body
  end

  
  it "raises an exception when something other than Hash or String" do
    authenticate
    
    begin
      response = @agent.post(@resource, [["a"],["b"]])
    rescue StandardError => e
      e.class.should == ArgumentError
    end
  end

  
  it "sends a DELETE request" do
    authenticate

    body = ''
    headers = @headers.merge(@accept)
    headers.merge!(@pp) if ShellForce.config.pp == true    
    
    stub_request(:delete, @instance_url + @resource).
      with(:headers => headers).to_return(:body => body)

    response = @agent.delete(@resource)
    response.body.should == body
  end

  
  it "sends a PATCH request" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge(@accept)
    headers.merge!(@content_type)
    headers.merge!(@pp) if ShellForce.config.pp == true
    
    request = '{"name" => "name"}'

    stub_request(:patch, @instance_url + @resource).
      with(:body => request, :headers => headers).to_return(:body => body)

    response = @agent.patch(@resource, request)
    response.body.should == body
  end

  it "raises an exception" do
    authenticate

    stub_request(:head, @instance_url + @wrong_resource).
      to_raise(ShellForce::ResponseCodeError.new(400))

    begin
      response = @agent.head(@wrong_resource)
    rescue ShellForce::ResponseCodeError => rce
      rce.response_code.should == 400
    end
  end

  it "tries to authenticate again and re-sends a request" do
    authenticate

    stub_request(:get, @instance_url + @wrong_resource).to_return({:status => 401}, {:status => 200})

    response = @agent.get(@wrong_resource)
    response.code.should == "200"
  end
  
  
  it "sends a query for db search" do
    authenticate

    submit_query('/query') do |r, q|
      @agent.query(r, q)
    end
  end

  
  it "sends a query for index search" do
    authenticate

    submit_query('/search') do |r, q|
      @agent.search(r, q)
    end
  end
  
end
