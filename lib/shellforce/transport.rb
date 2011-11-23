# coding : utf-8

require 'net/https'
require 'cgi'
require 'openssl'

# To suppress the warning message: "warning: peer certificate won't be verified in this SSL session"
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

# Monkey patch for 'PATCH' method
module Net
  class HTTP
    class Patch < Net::HTTPRequest
      METHOD = 'PATCH'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end
  end
end


module ShellForce
  class Transport

    def initialize(args={})
      @redirection_code = args[:redirection_code] || 302
      @follow_redirection = args[:follow_redirection] && true
      @redirection_limit = args[:redirection_limit] || 20
      @user_agent = args[:user_agent] ||
        'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6'
      @keep_alive_time = args[:keep_alive_time] || 300
      @headers = args[:headers] ||
        {
        "User-Agent" => @user_agent,
        "Keep-Alive" => "#{@keep_alive_time.to_s}",
        "Connection" => "Keep-Alive",        
        "Accept-Language" => "ja, en;q=0.7",
        "Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      }
      @log = args[:log] || nil
      @connection_cache = {}
    end
    
    attr_reader :redirection_code, :follow_redirection, :redirection_limit, :headers
    attr_accessor :user_agent, :keep_alive_time, :log

    
    def head(url, headers={})
      send(:method => :head, :url => url, :headers => headers)
    end
    
    
    def get(url, data='', headers={})
      send(:method => :get, :url => url, :data => data, :headers => headers)
    end

    
    def post(url, data, headers={})
      send(:method => :post, :url => url, :data => data, :headers => headers)
    end


    def patch(url, data, headers={})
      send(:method => :patch, :url => url, :data => data, :headers => headers)
    end


    def delete(url, headers={})
      send(:method => :delete, :url => url, :headers => headers)
    end


    def build_uri(url, data)
      uri(url, data).to_s
    end
    
    
    private

    def query(data)
      data.map {|k, v| [k, CGI.escape(v.to_s)].join('=') if k}.compact.join('&')
    end


    def uri(url, data)
      URI.parse(url).tap {|u| u.query = query(data) if data.is_a?(Hash) && data.size != 0}
    end


    def connect(uri)
      connection = (@connection_cache["#{uri.host}:#{uri.port}"] ||= {:object => nil, :last_request_time => nil})
      connection[:object] = net_http(uri) if connection[:object].nil? || !connection[:object].started?
      
      if connection[:last_request_time] && @keep_alive_time < Time.now.to_i - connection[:last_request_time]
        connection[:object].finish
      end

      connection[:last_request_time] = Time.now.to_i
      yield(connection[:object])
    end

    
    def net_http(uri)
      Net::HTTP.new(uri.host, uri.port).tap {|h|
        if uri.is_a?(URI::HTTPS)
          h.use_ssl = true
          h.verify_mode = OpenSSL::SSL::VERIFY_NONE          
        end
      }
    end

    
    def request(method, uri, headers)
      Net::HTTP.const_get(method.to_s.capitalize).new(uri.request_uri, headers)
    end

    
    def send(args, limit=@redirection_limit)
      raise RedirectLimitReachedError.new(@redirection_code, @redirection_limit) if limit == 0

      method = args[:method] or raise ArgumentError.new("method must be specified")
      url = args[:url] or raise ArgumentError.new("url must be specified")
      data = args[:data] || ''
      headers = args[:headers] || {}
      
      uri = uri(url, data)
      headers.merge!(@headers)      

      log_request(method, uri, headers) if log

      response = connect(uri) do |connection|
        connection.start unless connection.started?
        connection.request(request(method, uri, headers), data.is_a?(String) ? data : '')
      end
      
      log_response(response) if log
      
      if Net::HTTPResponse::CODE_TO_OBJ[response.code.to_s] <= Net::HTTPRedirection
        return response unless @follow_redirection

        log_redirection(response) if log
        
        redirect_method = (method == :head ? :head : :get)
        send({:method => redirect_method, :url => URI.join(url, response['Location']).to_s}, limit-1)
      else
        return response
      end
    end

    
    def log_request(method, uri, headers)
      path, query = uri.request_uri.split('?')
      
      log.info("#{Net::HTTP.const_get(method.to_s.capitalize)}: #{path}")
      
      log.debug("query: #{query}") if query != nil
      
      headers.each { |k, v|
        log.debug("request-header: #{k} => #{v}")
      }
    end

    
    def log_response(response)
      log.info("status: #{response.code}")
      
      response.each_header { |k, v|
        log.debug("response-header: #{k} => #{v}")        
      }
    end

    
    def log_redirection(response)
      log.info("follow redirection to: #{response['Location']}")      
    end
    
  end
end

