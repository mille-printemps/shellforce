# coding: utf-8

require 'openssl'
require 'shellforce/config'

module ShellForce
  module Util

    COUNTRY_NAME_MAX = 2
    OTHER_NAME_MAX = 64
    LOCAL_CONFIG = 'local_config.rb'

    def create_config
      display "Please enter information for creating a self-signed certificate."

      display "Country Name (2 letter code) [JP]: ", false
      country = ask
      country = "JP" if country == ""
        
      if country.size != 2
        display "The country name needs to be #{COUNTRY_NAME_MAX} bytes long."
        exit!
      end
      
      display "State or Province Name (full name) [Tokyo]: ", false
      state = ask
      state = "Tokyo" if state == ""

      if OTHER_NAME_MAX < state.size
        display "The state or province name needs to be #{OTHER_NAME_MAX} bytes long."
        exit!
      end
      
      display "Locality Name (e.g. city) [Tokyo]: ", false
      locality = ask
      locality = "Tokyo" if locality == ""

      if OTHER_NAME_MAX < locality.size
        display "The locality name needs to be #{OTHER_NAME_MAX} bytes long."
        exit!
      end
      
      display "Organization Name (e.g. company) [salesforce.com]: ", false
      organization = ask
      organization = "salesforce.com" if organization == ""

      if OTHER_NAME_MAX < organization.size
        display "The organization name needs to be #{OTHER_NAME_MAX} bytes long."
        exit!
      end
      
      display "Organizaitonal Unit Name (e.g. section) [salesforce.com Japan]: ", false
      unit = ask
      unit = "salesforce.com Japan" if unit == ""

      if OTHER_NAME_MAX < unit.size
        display "The organizational unit name needs to be #{OTHER_NAME_MAX} bytes long."
        exit!
      end
      
      display "Common Name (e.g. your name) []: ", false
      name = ask
      name = "" if name == ""

      if OTHER_NAME_MAX < name.size
        display "The organizational unit name needs to be #{OTHER_NAME_MAX} bytes long."
        exit!
      end

      subject_info = {
        'C' => country, 'ST' => state, 'L' => locality,
        'O' => organization, 'OU' => unit, 'CN' => name
      }
      
      create_local_config(ShellForce.home, LOCAL_CONFIG)
      create_cert(subject_info, ShellForce.config.private_key, ShellForce.config.cert)

      display("Configuring...")
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
  set :pp => true
  set :postprocess => [lambda{|h,b| print b; return h,b}]
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
      cert_body.not_before = Time.now
      cert_body.not_after = Time.local(2037, 12, 31, 23, 59, 59)
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

    
    # The following methods are cited from heroku gem
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

    
    def echo_off
      system "stty -echo"
    end

    
    def echo_on
      system "stty echo"
    end

    
    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    
    def ask_for_password_on_windows
      require "Win32API"
      char = nil
      password = ''

      while char = Win32API.new("crtdll", "_getch", [ ], "L").Call do
        break if char == 10 || char == 13 # received carriage return or newline
        if char == 127 || char == 8 # backspace and delete
          password.slice!(-1, 1)
        else
          # windows might throw a -1 at us so make sure to handle RangeError
          (password << char.chr) rescue RangeError
        end
      end
      puts
      return password
    end

    
    def ask_for_password
      echo_off
      password = ask
      puts
      echo_on
      return password
    end
    
    
    def ask_for_credentials
      puts "Enter your Salesforce.com credentials."

      print "User name: "
      user_name = ask

      print "Password: "
      password = running_on_windows? ? ask_for_password_on_windows : ask_for_password

      return user_name, password
    end
    
    
  end
end

