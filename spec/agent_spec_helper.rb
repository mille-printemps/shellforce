require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'webmock/rspec'
include WebMock::API

shared_context "agent_shared_context" do
  before {
    ShellForce.config.port = 3000
    ShellForce.config.host = 'https://localhost'
    ShellForce.config.site = 'https://login.salesforce.com'
    ShellForce.config.client_id = 'client_id'
    ShellForce.config.client_secret = 'client_secret'
    ShellForce.config.user_name = 'user'
    ShellForce.config.password = 'password'

    @agent = ShellForce::Agent.new    
    
    @host = [ShellForce.config.host, ShellForce.config.port].join(':')
    @instance_url = 'https://na1.salesforce.com'
    @organization_id = 'organization_id'    
    @issued_at = '123456789'
    @token = 'token'
    @refresh_token = 'refresh_token'
    @headers = {"Authorization" => "OAuth #{@token}"}
    
    @new_issued_at = '987654321'
    @new_token = 'new_token'
    @new_headers = {"Authorization" => "OAuth #{@new_token}"}

    @resource = '/resource'
  }
  
  def authenticate
    body_one = <<-BODY_ONE
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <head>
    <script type='text/javascript'>
        var url = 'https://login.salesforce.com';
    </script>
    </head>
</html>"
BODY_ONE
    
    body_two = <<-BODY_TWO
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <body>
    <form id='login_form' name='login' method='POST'>
        <input type='hidden' name='un'>
        <input type="text" name="username"/>
        <input type="text" name="pw"/>
    </form>
    <body>
</html>
BODY_TWO

    body_three = <<-BODY_THREE
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <head>
    <script type='text/javascript'>
        var url = '/setup/secur/RemoteAccessAuthorizationPage.apexp';
    </script>
    </head>
</html>
BODY_THREE

    body_four = <<-BODY_FOUR
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <head>
    <script type='text/javascript'>
        var url = '#{@host + OmniAuth.config.path_prefix + "/forcedotcom/callback"}';
    </script>
    </head>
</html>
BODY_FOUR

    body_five = <<-BODY_FIVE
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <body>
    <p>
{"signature":"signature","uid":null,"instance_url":"#{@instance_url}",\
"credentials":{"token":"#{@organization_id}!#{@token}"},"issued_at":"#{@issued_at}",\
"refresh_token":"#{@refresh_token}","provider":"forcedotcom"}
    </p>
    </body>
</html>
BODY_FIVE
    
    stub_request(:get, @host + OmniAuth.config.path_prefix + '/forcedotcom').
      to_return(:body => body_one, :headers => {'Content-Type' => 'text/html'})
    
    stub_request(:get, 'https://login.salesforce.com').
      to_return(:body => body_two, :headers => {'Content-Type' => 'text/html'})
    
    stub_request(:post, 'https://login.salesforce.com').
      to_return(:body => body_three, :headers => {'Content-Type' => 'text/html'})
    
    stub_request(:get, 'https://login.salesforce.com/setup/secur/RemoteAccessAuthorizationPage.apexp').
      to_return(:body => body_four, :headers => {'Content-Type' => 'text/html'})
    
    stub_request(:get, @host + OmniAuth.config.path_prefix + '/forcedotcom/callback').
      to_return(:body => body_five, :headers => {'Content-Type' => 'text/html'})

    @agent.authenticate

    @agent.instance_url.should == @instance_url
    @agent.issued_at.should == @issued_at
    @agent.organization_id.should == @organization_id
    @agent.token.should == @token
    @agent.headers.should == @headers
  end

  def submit_query(resource, &block)
    body = '{"totalSize":0}'
    headers = @headers.merge({"Accept" => "application/#{ShellForce.config.format}"})
    query = {'q' => 'a'}

    stub_request(:get, @instance_url + @resource + resource).
      with(:query => query, :headers => headers).
      to_return(:body => body)

    response = block.call(@resource, 'a')
    response.should == body
  end
  
end

