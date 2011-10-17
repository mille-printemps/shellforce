# coding : utf-8

module ShellForce
  class ResponseCodeError < RuntimeError
    def initialize(response_code)
      @response_code = response_code
    end

    def to_s
      "#{response_code} => #{Net::HTTPResponse::CODE_TO_OBJ[response_code]}"      
    end

    def inspect
      to_s
    end

    attr_reader :response_code
  end

  
  class RedirectLimitReachedError < RuntimeError
    def initialize(response_code, redirection_limit)
      @response_code = response_code
      @redirection_limit = redirection_limit
    end

    def to_s
      "Maximum redirection limit (#{redirection_limit}) reached"
    end

    def inspect
      to_s
    end
    
    attr_reader :response_code, :redirection_limit
  end

  
  class CallbackError < RuntimeError
    def initialize(error_code, error_description)
      @error_code = error_code
      @error_description = @@error_reason[error_description]
    end

    def to_s
      "#{@error_code} => #{@error_description}"
    end

    def inspect
      to_s
    end

    attr_reader :error, :error_

    private
    
    @@error_reason = {
        'unsupported_response_type' => 'Response type not supported',
        'invalid_client_id' => 'Client identifier invalid',
        'invalid_request' => 'HTTPS required',
        'invalid_request' => 'Must use HTTP GET',
        'access_denied' => 'End-user denied authorization',
        'redirect_uri_missing' => 'Redirect_uri not provided',
        'redirect_uri_mismatch' => 'Redirect_uri mismatch with remote access application definition',
        'immediate_unsuccessful' => 'Immediate unsuccessful',
        'invalid_scope' => 'Requested scope is invalid, unknown, or malformed'
      }
    
  end
  
end

