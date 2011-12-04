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


@@client = nil

# Request handlers
get ShellForce.config.auth_path + '/callback' do
  args = JSON.parse(request.env['shellforce.oauth2'])
  args.keys.each{|k| args[k.to_sym] = args[k]; args.delete(k)}
  @@client = ShellForce::Client.new(args)
  redirect ShellForce.config.path
end


get ShellForce.config.path do
  redirect ShellForce.config.auth_path unless @@client
  haml :index
end


post "#{shellforce_api}" do
  # Parse parameters
  path = params[:path]
  method = params[:method]
  url = params[:url]
  body = params[:body]

  # Depending on the method, call the REST APIs
  begin
    set_current_path(path)
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
                 "{\"error\" : \"Illegal method : #{method}\"}"
               end
    if response.is_a?(Array) && response.length == 2
      "{\"raw\" : #{response[0]}, \"clickable\" : #{make_link_clickable(response[0])}, \"time\" : \"#{response[1]}\"}"
    else
      "{\"error\" : \"Illegal response : #{response}\"}"
    end
  rescue => e
      "{\"error\" : \"#{e.message}\"}"
  end
  
end


# Utility functions
def make_link_clickable(body)
  body = body.gsub(/(\/services\/data\/v\d+\.\d+\/[^\"]*)/){ |match|
    match = '<a href=\'javascript:void(0);\' onclick=' + sprintf("\'getSObjectRecord(\\\"%s\\\");\'", $1) + '>' + match + '</a>'
  }

  body = body.gsub(/(https:\/\/login.salesforce.com)(\/id\/[^\"]*)/){ |match|
    match = '<a href=\'javascript:void(0);\' onclick=' + sprintf("\'getSObjectRecord(\\\"%s\\\");\'", $2) + '>' + $2 + '</a>'
  }

  body
end


def set_current_path(path)
  if /\/services\/data\/v\d+\.\d+/ =~ path
    @@client.to(:data)
  elsif /\/services\/apexrest/ =~ path
    @@client.to(:apex)
  elsif path == ''
    @@client.to(:root)
  else
    @@client.to(:root)
  end
end
