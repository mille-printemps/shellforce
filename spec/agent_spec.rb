# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/agent_spec_helper')

require 'webmock/rspec'
include WebMock::API

describe ShellForce::Agent do
 include_context "agent_shared_context"
  
  it "pings" do
    body = []    
    stub_request(:get, @host).to_return(:body => '[]')
    response = @agent.ping
    response.should == body
  end

  it "refreshes a token" do
    
    # Authenticate first to initialize the refresh token
    # This is done in the rest of the tests
    authenticate

    # Then, refresh the token
    body_six = <<-BODY_SIX
{"signature":"signature","instance_url":"#{@instance_url}",\
"access_token":"#{@organization_id}!#{@new_token}","issued_at":"#{@new_issued_at}"}
BODY_SIX

    request = {
        'grant_type' => 'refresh_token',
        'client_id' => ShellForce.config.client_id,
        'client_secret' => ShellForce.config.client_secret,
        'refresh_token' => @refresh_token
    }
    
    stub_request(:post, ShellForce.config.site + '/services/oauth2/token').
      with(:body => request, :headers => {'Accept' => 'application/json'}).
      to_return(:body => body_six, :heaers => {'Content-Type' => 'application/json'})

    @agent.refresh

    @agent.issued_at.should == @new_issued_at
    @agent.token.should == @new_token
    @agent.headers.should  == @new_headers

  end

  it "gets" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})

    stub_request(:get, @instance_url + @resource).
      with(:headers => headers).
      to_return(:body => body)
    
    response = @agent.get(@resource)
    response.should == body
  end

  it "posts a string" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})
    headers.merge!({"Content-Type" => "application/#{ShellForce.config.format}"})
    request = '{"name" => "name"}'
    
    stub_request(:post, @instance_url + @resource).
      with(:body => request, :headers => headers).
      to_return(:body => body)

    response = @agent.post(@resource, request)
    response.should == body
  end

  it "posts a hash or an array" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})
    headers.merge!({"Content-Type" => "application/#{ShellForce.config.format}"})
    query = {"a" => "b", "c" => "d"}

    stub_request(:post, @instance_url + @resource).
      with(:query => query, :headers => headers).
      to_return(:body => body)

    response = @agent.post(@resource, query)
    response.should == body

    response = @agent.post(@resource, [["a","b"],["c","d"]])
    response.should == body
  end

  it "deletes" do
    authenticate

    body = ''
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})
    
    stub_request(:delete, @instance_url + @resource).
      with(:headers => headers).
      to_return(:body => body)

    response = @agent.delete(@resource)
    response.should == body
  end

  it "patches" do
    authenticate

    body = '{"totalSize":0}'
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})
    headers.merge!({"Content-Type" => "application/#{ShellForce.config.format}"})
    request = '{"name" => "name"}'

    stub_request(:patch, @instance_url + @resource).
      with(:body => request, :headers => headers).
      to_return(:body => body)

    response = @agent.patch(@resource, request)
    response.should == body
  end
    
  it "queries" do
    authenticate

    submit_query('/query') do |r, q|
      @agent.query(r, q)
    end
  end

  it "searches" do
    authenticate

    submit_query('/search') do |r, q|
      @agent.search(r, q)
    end
  end
  
end
