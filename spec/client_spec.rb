# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/agent_spec_helper')

require 'webmock/rspec'
include WebMock::API

describe ShellForce::Client do
  include_context "agent_shared_context"

  before do
    initialize
    
    body = <<-BODY
[{"label":"Winter '11","url":"/services/data/v20.0","version":"20.0"},\
{"label":"Spring '11","url":"/services/data/v21.0","version":"21.0"},\
{"label":"Summer '11","url":"/services/data/v22.0","version":"22.0"},\
{"label":"Winter '12","url":"/services/data/v23.0","version":"23.0"}]
BODY
    
    stub_request(:get, @instance_url + '/services/data').to_return(:body => body)
    @client = ShellForce::Client.new    
  end
  
  
  it "gets initialized" do
    @client.current_path.should == '/services/data/v23.0'
    @client.instance_url.should == @instance_url
    @client.organization_id.should == @organization_id
    @client.token.should == @token
    @client.issued_at.should == @issued_at
  end

  it "changes the api types" do
    @client.to(:apex).should == '/services/apexrest'
    @client.to(:data).should == '/services/data/v23.0'
    @client.to(:apex).should == '/services/apexrest'
    @client.to(:none).should == 'none is not supported'
  end
  
end
