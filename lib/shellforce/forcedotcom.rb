# -*- coding: utf-8 -*-

require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Forcedotcom < OAuth2

      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://login.salesforce.com",
          :authorize_path => "/services/oauth2/authorize",
          :access_token_path => "/services/oauth2/token"
        }

        options.merge!(:response_type => 'code', :grant_type => 'authorization_code')

        super(app, :forcedotcom, client_id, client_secret, client_options, options, &block)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {'instance_url' => @access_token['instance_url']})
      end
    end
  end
end
