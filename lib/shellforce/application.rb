# coding: utf-8

require 'rubygems'
require 'sinatra/base'
require 'json'
require 'haml'
require 'shellforce/config'
require 'shellforce/client'

def shellforce_api
  ShellForce.config.path + '/api'
end

module ShellForce
  class Application < Sinatra::Base

    get ShellForce.config.auth_path + '/callback' do
      @@client = ShellForce::Client.new(JSON.parse(request.env['shellforce.oauth2']))
      redirect ShellForce.config.path
    end

    get ShellForce.config.path do
      haml :index
    end

    post "#{shellforce_api}" do
      # parse parameters
      method = params[:method]
      url = params[:url]
      body = params[:body]

      # depending on the parameters, call
      response = case method
                 when 'GET'
                   @@client.get(url)
                 when 'POST'
                   @@client.post(url, body)
                 when 'PATCH'
                   @@client.patch(url, body)
                 when 'DELETE'
                   @@client.delete(url)
                 when 'QUERY'
                   @@client.query(url)
                 when 'SEARCH'
                   @@client.search(url)
                 else
                   '{"error" : "Illegal method : #{method}"}'
                 end
      if response.is_a?(Array) && response.length == 2
        response[0]
      else
        '{"error" : "Illegal response : #{response}"}'        
      end
    end
    
  end
end


