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
    
end

