# coding: utf-8

require 'rubygems'
require 'sinatra/base'
require 'json'
require 'shellforce/config'
require 'shellforce/client'

# returns an oauth2 token and ohter information in a json format
module ShellForce
  class Application < Sinatra::Base

    get ShellForce.config.path + '/callback' do
      request.env['shellforce.oauth2']
    end
    
  end
end


