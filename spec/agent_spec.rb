# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/agent_spec_helper')

require 'webmock/rspec'
include WebMock::API

describe ShellForce::Agent do
  include_context "agent_shared_context"

  it "can be intialized by arguments" do
    args = {:signature => "#{@signature}", :id => "#{@id}", :instance_url => "#{@instance_url}",\
      :access_token => "#{@organization_id}!#{@token}", :issued_at => "#{@issued_at}"}
    
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
      :instance_url => @instance_url,
      :issued_at => @issued_at,
      :signature => @signature,
      :access_token => "#{@organization_id}!#{@token}",
      :refresh_token => @refresh_token
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

    check_with_nothing(:head) do
      @agent.head(@resource)
    end
  end


  it "sends a GET request" do
    authenticate

    check_with_nothing(:get) do
      @agent.get(@resource)
    end
  end

  
  it "sends a POST request with a string" do
    authenticate

    payload = '{"q" : "a"}'

    check_with_string(:post, payload, @content_type) do
      @agent.post(@resource, payload)      
    end
  end

  
  it "sends a POST request with a hash" do
    authenticate

    payload = {"q" => "a"}

    check_with_query(:post, payload, "Content-Type" => "application/x-www-form-urlencoded") do
      @agent.post(@resource, payload)      
    end
  end

  
  it "sends a PUT request with a string" do
    authenticate

    payload = '{"q" : "a"}'

    check_with_string(:put, payload, @content_type) do
      @agent.put(@resource, payload)      
    end
  end

  
  it "sends a PUT request with a hash" do
    authenticate

    payload = {"q" => "a"}

    check_with_query(:put, payload, "Content-Type" => "application/x-www-form-urlencoded") do
      @agent.put(@resource, payload)      
    end
  end

  
  it "sends a PATCH request with a string" do
    authenticate

    payload = '{"q" : "a"}'

    check_with_string(:patch, payload, @content_type) do
      @agent.patch(@resource, payload)      
    end
  end

  
  it "sends a PATCH request with a hash" do
    authenticate

    payload = {"q" => "a"}

    check_with_query(:patch, payload, "Content-Type" => "application/x-www-form-urlencoded") do
      @agent.patch(@resource, payload)      
    end
  end

  it "raises an exception when something other than Hash or String" do
    authenticate
    
    begin
      response = @agent.post(@resource, [["a"],["b"]])
    rescue StandardError => e
      e.class.should == ArgumentError
    end

    begin
      response = @agent.put(@resource, [["a"],["b"]])
    rescue StandardError => e
      e.class.should == ArgumentError
    end

    begin
      response = @agent.patch(@resource, [["a"],["b"]])
    rescue StandardError => e
      e.class.should == ArgumentError
    end    
  end

  
  it "sends a DELETE request" do
    authenticate

    check_with_nothing(:delete) do
      @agent.delete(@resource)
    end
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

    payload = {"q" => "a"}
    
    check_with_query(:get, payload, {}, '/query') do
      @agent.query(@resource, "a")
    end
  end

  
  it "sends a query for index search" do
    authenticate

    payload = {"q" => "a"}    
    
    check_with_query(:get, payload, {}, '/search') do
      @agent.search(@resource, "a")
    end
  end

end
