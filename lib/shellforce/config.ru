# coding: utf-8

require 'rubygems'
require 'rack'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'shellforce/config'
require 'shellforce/oauth2'
require 'shellforce/application'


configuration = {
:Port => ShellForce.config.port,
:DocumentRoot => ShellForce.config.document_root,
:SSLEnable => true,
:SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
:SSLPrivateKey => OpenSSL::PKey::RSA.new(File.read(ShellForce.config.private_key)),
:SSLCertificate => OpenSSL::X509::Certificate.new(File.read(ShellForce.config.cert)),
:SSLCertName => [["CN", WEBrick::Utils::getservername]],
:Logger => ShellForce.config.server_logger,
:AccessLog => ShellForce.config.server_access_logger
}

application = Rack::Session::Cookie.new(
  ShellForce::OAuth2.new(
    ShellForce::Application.new
  )
)

Rack::Handler::WEBrick.run application, configuration

