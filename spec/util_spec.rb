# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ShellForce::Util do
  include ShellForce::Util

  before do
    @config = 'test_local_config.rb'
    @local_config = File.join(ShellForce.home, @config)

    @private_key = File.join(ShellForce.home, 'test_key.pem')
    @cert = File.join(ShellForce.home, 'test_cert.pem')
  end

  
  it "creates local_config.rb on home directory" do

    create_local_config(ShellForce.home, @config)

    File.exist?(@local_config).should == true
    
    mode = sprintf("%o", File.stat(ShellForce.home).mode)
    mode.should == '40700'
    
    mode = sprintf("%o", File.stat(@local_config).mode)
    mode.should == '100600'

    require(@local_config)

    ShellForce.config.use :default    

    ShellForce.config.client_id.should == ''
    ShellForce.config.client_secret.should == ''
    ShellForce.config.pp.should == false
    ShellForce.config.logging.should == false

    FileUtils.remove(@local_config) if File.exists?(@local_config)  
  end

  
  it "creates key and cert files on home directory" do

    subject_info = {
        'C' => 'JP', 'ST' => 'Tokyo', 'L' => 'Tokyo',
        'O' => 'salesforce.com', 'OU' => 'salesforce.com Japan', 'CN' => 'salesforce.com'
    }

    create_cert(subject_info, @private_key, @cert)

    File.exists?(@private_key).should == true
    File.exists?(@cert).should == true    

    mode = sprintf("%o", File.stat(@private_key).mode)
    mode.should == '100600'

    mode = sprintf("%o", File.stat(@cert).mode)
    mode.should == '100600'

    FileUtils.remove(@private_key) if File.exists?(@private_key)
    FileUtils.remove(@cert) if File.exists?(@cert)
  end
  
end

