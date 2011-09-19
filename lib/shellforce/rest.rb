# coding : utf-8

require 'rubygems'
require 'mechanize'
require 'shellforce/config'

module ShellForce
  class Rest
    def self.request(*args, &block)
      begin
        start = Time.now
        response_body = block.call(*args)
        stop = Time.now
        return response_body, stop-start
      rescue Mechanize::ResponseCodeError => rce
        raise rce.response_code + ' : ' + @@response_code_description[rce.response_code]
      rescue Mechanize::RedirectLimitReachedError        
      rescue ArgumentError
      rescue EOFError
      rescue StandardError
        raise $!
      end
    end

    private

    @@response_code_description = {
      '300' => 'The value used for an external ID exists in more than one record. The response boby contains the list of matching records.',

      '400' => 'The request could not be understood, usually because the JSON or XML body has an error. ',

      '401' => 'The session ID or OAuth token used has expired or is invalid. The response body contains the message and errorCode. ',

      '403' => 'The request has been refused. Verify that the logged-in user has appropriate permissions. ',

      '404' => 'The requested resource could not be found. Check the URI for errors, and verify that there are no sharing issues. ',

      '405' => 'The method specified in the Request-Line is not allowed for the resource specified in the URI. ',

      '415' => 'The entity specified in the request is in a format that is not supported by specified resource for the specified method.',

      '500' => 'An error has occurred within Force.com, so the request could not be completed. Contact salesforce.com Customer Support. '
    }

  end
end

