# coding : utf-8

require 'rubygems'
require 'tempfile'
require 'mime/types'

module ShellForce
  class Payload
    NEWLINE = "\r\n"
    BOUNDARY = "boundary-string"

    def initialize(data, headers, format)
      @format = format
      @headers = headers.merge({"Accept" => "application/#{@format}"})
      if data.is_a?(String)
        @headers.merge!({"Content-Type" => "application/#{@format}"}) unless data.empty?
        @data = data
      elsif data.is_a?(Hash)
        if has_file?(data)
          @headers.merge!({"Content-Type" => "multipart/form-data; boundary=\"#{boundary}\""})
          @data = create_multipart_body(data)
        else
          @headers.merge!({"Content-Type" => "application/x-www-form-urlencoded"})
          @data = data
        end
      else
        raise ArgumentError.new("data must be a string or a hash")
      end
    end

    attr_reader :data, :headers

    
    def boundary
      BOUNDARY
    end

    private
    
    def create_multipart_body(data)
      b = "--#{boundary}"

      @stream = Tempfile.new("ShellForce.#{rand(1000)}")
      @stream.binmode
      @stream.write(b + NEWLINE)
      
      count = 0
      data.each do |k,v|
        if v.respond_to?(:path) && v.respond_to?(:read)
          create_file_body(@stream, k, v)
        else
          create_metadata_body(@stream, k, v)
        end
        @stream.write(NEWLINE)
        @stream.write(NEWLINE + b)
        @stream.write(NEWLINE) unless count == data.size-1
        count += 1
      end
      @stream.write('--')
      @stream.write(NEWLINE)
      @stream.seek(0)
      @stream.read
    end

    
    def create_metadata_body(s, k, v)
      s.write("Content-Disposition: form-data; name=\"#{k}\";#{NEWLINE}")
      s.write("Content-Type: application/#{@format}#{NEWLINE}")
      s.write(NEWLINE)
      s.write(v)
    end

    
    def create_file_body(s, k, v)
      begin
        s.write("Content-Disposition: form-data;")
        s.write(" name=\"#{k}\";")
        s.write(" filename=\"#{v.respond_to?(:original_filename) ? v.original_filename : File.basename(v.path)}\"#{NEWLINE}")        
        s.write("Content-Type: #{v.respond_to?(:content_type) ? v.content_type : mime_for(v.path)}#{NEWLINE}")
        s.write(NEWLINE)
        while data = v.read(8124)
          s.write(data)
        end
      ensure
        v.close if v.respond_to?(:close)
      end
    end

    
    def mime_for(path)
        mime = MIME::Types.type_for(path)
        mime.empty? ? 'text/plain' : mime[0].content_type
    end

    
    def has_file?(data)
      data.any? do |k,v|
        v.respond_to?(:path) && v.respond_to?(:read)
      end
    end
    
  end
end

