# coding: utf-8

require 'rubygems'
require 'rack'
require 'omniauth'
require 'webrick'
require 'webrick/https'
require 'shellforce/forcedotcom'
require 'shellforce/config'
require 'shellforce/auth'

OmniAuth.config.full_host = [ShellForce.config.host, ShellForce.config.port].join(':')

configuration = {
:Port => ShellForce.config.port,
:DocumentRoot => ShellForce.config.document_root,
:SSLEnable => true,
:SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
:SSLPrivateKey => OpenSSL::PKey::RSA.new(File.open(ShellForce.config.private_key).read),
:SSLCertificate => OpenSSL::X509::Certificate.new(File.open(ShellForce.config.cert).read),
:SSLCertName => [["CN", WEBrick::Utils::getservername]],
:Logger => ShellForce.config.logger
}

application = Rack::Session::Cookie.new(
  OmniAuth::Builder.new ShellForce::Auth.new do
    provider :forcedotcom, ShellForce.config.client_id, ShellForce.config.client_secret    
  end
)

Rack::Handler::WEBrick.run application, configuration

