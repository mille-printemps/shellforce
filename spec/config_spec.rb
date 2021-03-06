# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ShellForce::Configuration do
  
  it "configures a home directory by default" do
    
    ShellForce.home.should == ENV["HOME"] + '/.shellforce'
    
  end

  
  it "selects another configurarion" do
    
    client_id = 'client_id'
    client_secret = 'client_secret'
    
    ShellForce.configure :another do
      set :client_id => client_id
      set :client_secret => client_secret
    end

    ShellForce.config.use :another

    ShellForce.config.client_id.should == client_id
    ShellForce.config.client_secret.should == client_secret
  end

  
  it "overrides parameters in a configuration" do

    new_client_id = 'new_client_id'
    new_client_secret = 'new_client_secret'
    
    ShellForce.configure :another do
      set :client_id => 'client_id'
      set :client_secret => 'client_secret'
    end

    ShellForce.configure :another do
      set :client_id => new_client_id
      set :client_secret => new_client_secret
    end

    ShellForce.config.use :another    
    
    ShellForce.config.client_id.should == new_client_id
    ShellForce.config.client_secret.should == new_client_secret
  end

  
  it "copies one to another" do

    ShellForce.config.copy(:default, :another)
    ShellForce.config[:default].each_pair{|k ,v|
      v.should == ShellForce.config[:another][k]
      v.should_not equal(ShellForce.config[:another][k]) if v != nil && (v.is_a?(String) || v.is_a?(Array) || v.is_a?(Hash))
    }
    
  end
  
  
end

