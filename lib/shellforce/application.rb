# coding: utf-8

require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'
require 'shellforce/config'
require 'shellforce/client'

# Functions that retrieve information from the server
def shellforce_api
  ShellForce.config.path + '/api'
end

def shellforce_current_path
  @@client.current_path
end


# Request handlers
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
               # TODO : if url starts with '/id', then change the current path
               @@client.get(url)
             when 'POST'
               # TODO : make sure if the current path is correct
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
    # TODO : make a json string with the body and the elapsed time
    response[0]
  else
    '{"error" : "Illegal response : #{response}"}'
  end
end


# Utility functions
def make_link_clickable(body)
  clickableBody = body.gsub(/(\/services\/data\/v\d+\.\d+)(\/sobjects\/[^\"]*)/){ |match|
    match = '<a href=' + sprintf("\'javascript:getSObjectRecord(\"%s%s\")\'", $1, $2) + '>' + match + '</a>'
  }

  clickableBody.gsub!(/(https:\/\/login.salesforce.com)(\/id\/[^\"]*)/){ |match|
    match = '<a href=' + sprintf("\'javascript:getSObjectRecord(\"%s\")\'", $2) + '>' + $2 + '</a>'
  }
end
