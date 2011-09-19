# coding: utf-8

require 'openssl'
require 'shellforce/config'

module ShellForce
  module Util

    COUNTRY_NAME_MAX = 2
    OTHER_NAME_MAX = 64
    LOCAL_CONFIG = 'local_config.rb'

    def create_config
      display 'Please give information for creating a self-signed certificate.'

      display 'Country Name (2 letter code) [JP]: ', false
      country = ask
      country = "JP" if country == "\n"
        
      if country.size != 2
        display 'The country name needs to be #{COUNTRY_NAME_MAX} bytes long.'
        exit!
      end
      
      display 'State or Province Name (full name) [Tokyo]: ', false
      state = ask
      state = "Tokyo" if state == "\n"

      if OTHER_NAME_MAX < state.size
        display 'The state or province name needs to be #{OTHER_NAME_MAX} bytes long.'
        exit!
      end
      
      display 'Locality Name (e.g. city) [Tokyo]: ', false
      locality = ask
      locality "Tokyo" if locality == "\n"

      if OTHER_NAME_MAX < locality.size
        display 'The locality name needs to be #{OTHER_NAME_MAX} bytes long.'
        exit!
      end
      
      display 'Organization Name (e.g. company) [salesforce.com]: ', false
      organization = ask
      organization = "salesforce.com" if organization == "\n"

      if OTHER_NAME_MAX < organization.size
        display 'The organization name needs to be #{OTHER_NAME_MAX} bytes long.'
        exit!
      end
      
      display 'Organizaitonal Unit Name (e.g. section) [salesforce.com Japan]: ', false
      unit = ask
      unit = "salesforce.com Japan" if unit == "\n"

      if OTHER_NAME_MAX < unit.size
        display 'The organizational unit name needs to be #{OTHER_NAME_MAX} bytes long.'
        exit!
      end
      
      display 'Common Name (e.g. your name) []: ', false
      name = ask
      name = "" if name == "\n"

      if OTHER_NAME_MAX < name.size
        display 'The organizational unit name needs to be #{OTHER_NAME_MAX} bytes long.'
        exit!
      end

      subject_info = {
        'C' => country, 'ST' => state, 'L' => locality,
        'O' => organization, 'OU' => unit, 'CN' => name
      }
      
      create_local_config(ShellForce.home, LOCAL_CONFIG)
      create_cert(subject_info, ShellForce.config.private_key, ShellForce.config.cert)

      display("#{LOCAL_CONFIG} is created under #{ShellForce.config.home}")
    end

    
    def create_local_config(home, config)
      
      if !File.exists?(home) || !File.directory?(home)
        Dir::mkdir(home)
      end

      default = <<-CONFIG
require 'shellforce/config'

ShellForce.configure :default do
  set :client_id => ''
  set :client_secret => ''
  set :pp => false
  set :logging => false 
end
CONFIG

      local_config = File.join(home, config)
      File.open(local_config, 'w') do |file|
        file.write(default)
      end

      FileUtils.chmod 0700, home
      FileUtils.chmod 0600, local_config
    end

    
    def create_cert(subject_info, private_key, cert)
      key = OpenSSL::PKey::RSA.new(1024)
      digest = OpenSSL::Digest::SHA1.new
      
      File.open(private_key, 'w') do |file|
        file.write(key.to_pem)
      end
      
      issuer = subject = OpenSSL::X509::Name.new
      subject_info.each {|k,v| subject.add_entry(k, v)}

      cert_body = OpenSSL::X509::Certificate.new
      cert_body.not_before = Time.at(0)
      cert_body.not_after = Time.at(0)
      cert_body.public_key = key
      cert_body.serial = 1
      cert_body.issuer = issuer
      cert_body.subject = subject

      cert_body.sign(key, digest)

      File.open(cert, 'w') do |file|
        file.write(cert_body.to_pem)
      end

      FileUtils.chmod 0600, private_key
      FileUtils.chmod 0600, cert
    end

    
    # The following two methods are cited from heroku gem
    def display(text, newline=true)
      if newline
        puts(text)
      else
        print(text)
        STDOUT.flush
      end
    end

    
    def ask
      gets.strip
    end
    
  end
end

