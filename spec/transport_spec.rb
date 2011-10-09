# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/agent_spec_helper')

require 'webmock/rspec'
include WebMock::API

shared_context "transport_shared_context" do
  
  def redirect(url_or_path)
    transport = ShellForce::Transport.new(:redirection_limit => 1)
    redirection_url = url_or_path
    
    stub_request(:get, @url).with(:headers => @headers).
      to_return(:status => 302, :body => @body, :headers => {'Location' => redirection_url})

    stub_request(:get, redirection_url).with(:headers => @headers).to_return(:body => @body)

    begin
      response = transport.get(@url, '', @headers)
    rescue ShellForce::RedirectLimitReachedError => rlre
      rlre.response_code.should == 302
      rlre.redirection_limit.should == 1
    end
  end
end


describe ShellForce::Transport do
  include_context "transport_shared_context"
  
  before(:each) do
    @transport = ShellForce::Transport.new
    @url = "https://login.salesforce.com/"
    @body = "body"
    @headers = {"Authorization" => "OAuth"}
  end
  
  it "sends a HEAD request" do
    stub_request(:head, @url).with(:headers => @headers).to_return(:body => @body)

    response = @transport.head(@url, @headers)
    response.body.should == @body
  end


  it "sends a GET request" do
    stub_request(:get, @url).with(:headers => @headers).to_return(:body => @body)

    response = @transport.get(@url, '', @headers)
    response.body.should == @body
  end

  
  it "sends a GET request with a query" do
    data = {"a" => "b", "c" => "d"}
    
    stub_request(:get, @url).with(:query => data, :headers => @headers).to_return(:body => @body)

    response = @transport.get(@url, data, @headers)
    response.body.should == @body
  end
  
  
  it "sends a POST request with a string" do
    data = "data"

    stub_request(:post, @url).with(:body => data, :headers => @headers).to_return(:body => @body)

    response = @transport.post(@url, data, @headers)
    response.body.should == @body
  end

  
  it "sends a POST request with a query" do
    data = {"a" => "b", "c" => "d"}

    stub_request(:post, @url).with(:query => data, :headers => @headers).to_return(:body => @body)

    response = @transport.post(@url, data, @headers)
    response.body.should == @body
  end
  

  it "sends a PATCH request" do
    data = "data"

    stub_request(:patch, @url).with(:body => data, :headers => @headers).to_return(:body => @body)

    response = @transport.patch(@url, data, @headers)
    response.body.should == @body
  end

  
  it "sends a DELETE request" do
    body = ''

    stub_request(:delete, @url).with(:headers => @headers).to_return(:body => body)

    response = @transport.delete(@url, @headers)
    response.body.should == body
  end

  
  it "does not redirect" do
    transport = ShellForce::Transport.new(:follow_redirection => false)    
    redirection_url = 'https://na7.salesforce.com/'
    
    stub_request(:get, @url).with(:headers => @headers).
      to_return(:status => 302, :body => @body, :headers => {'Location' => redirection_url})

    response = transport.get(@url, '', @headers)
    response.code.should == "302"
    response.body.should == @body
  end
  
  
  it "redirects to a absolute path" do
    redirect('https://login.salesforce.com/')
  end

  
  it "redirects to a relative path" do
    redirect('/path')
  end

  
  it "makes a log file and logs" do
    require 'logger'
    log_file = File.join(File.dirname(__FILE__) + '/log.txt')
    @transport.log = Logger.new(log_file)
    redirect('/path')

    File.exists?(log_file).should == true
    File.read(log_file).size != 0
    FileUtils.remove(log_file)
  end
end



