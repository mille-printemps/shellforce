# coding: utf-8

require 'rubygems'
require 'sinatra/base'
require 'omniauth'
require 'json'

# returns an instance url and token in a json format
module ShellForce
  class Auth < Sinatra::Base
    get '/' do
      JSON.generate([])
    end
    
    get OmniAuth.config.path_prefix + '/forcedotcom/callback' do
      auth = request.env['omniauth.auth']
      JSON.generate(auth)     
    end
  end
end


