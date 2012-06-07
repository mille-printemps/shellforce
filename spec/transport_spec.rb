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

  
  def check(method, additional_param, body)
    stub_request(method, @url).with(additional_param.merge(:headers => @headers)).to_return(:body => body)

    response = yield
    response.body.should == body
  end
end


describe ShellForce::Transport do
  include_context "transport_shared_context"
  
  before(:each) do
    @transport = ShellForce::Transport.new
    @url = "https://login.salesforce.com/"
    @body = "body"
    @headers = {"Authorization" => "Bearer"}
  end

  
  it "sends a HEAD request" do
    check(:head, {}, @body) do
      @transport.head(@url, @headers)      
    end
  end

  
  it "sends a GET request" do
    check(:get, {}, @body) do
      @transport.get(@url, '', @headers)      
    end
  end

  
  it "sends a GET request with a query" do
    data = {"a" => "b", "c" => "d"}
    
    check(:get, {:query => data}, @body) do
      @transport.get(@url, data, @headers)      
    end
  end

  
  it "sends a POST request with a string" do
    data = "data"

    check(:post, {:body => data}, @body) do    
      @transport.post(@url, data, @headers)
    end
  end

  
  it "sends a POST request with a query" do
    data = {"a" => "b", "c" => "d"}

    check(:post, {:query => data}, @body) do    
      @transport.post(@url, data, @headers)
    end
  end

  
  it "sends a PUT request with a string" do
    data = "data"

    check(:put, {:body => data}, @body) do    
      @transport.put(@url, data, @headers)
    end
  end

  
  it "sends a PUT request with a query" do
    data = {"a" => "b", "c" => "d"}

    check(:put, {:query => data}, @body) do    
      @transport.put(@url, data, @headers)
    end
  end

  
  it "sends a PATCH request with a string" do
    data = "data"

    check(:patch, {:body => data}, @body) do    
      @transport.patch(@url, data, @headers)
    end
  end

  
  it "sends a PATCH request with a query" do
    data = {"a" => "b", "c" => "d"}

    check(:patch, {:query => data}, @body) do    
      @transport.patch(@url, data, @headers)
    end
  end

  
  it "sends a DELETE request" do
    check(:delete, {}, '') do
      @transport.delete(@url, @headers)      
    end
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



