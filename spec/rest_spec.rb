# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ShellForce::Rest do
  
  it "executes a block and returns its result and response time" do

    ShellForce.config.postprocess = [lambda{|h, b| return h, b}]
    
    # A dummy response
    response = []
    class << response
      def body
        "abc"
      end

      def to_hash
        {"content-type" => ["application/json"]}
      end
    end
    
    method = lambda {|a,b,c| return response}
    
    result = ShellForce::Rest.request("a", "b", "c") do |a, b, c|
      method.call(a,b,c)
    end

    result[0].should == "abc"
    result[1].zero?.should == false
  end

  
  it "raises an exception raised by the block" do

    method = lambda {|a,b,c| raise StandardError}

    begin
      result = ShellForce::Rest.request("a", "b", "c") do |a, b, c|
        method.call(a,b,c)
      end
    rescue StandardError => e
      e.exception.to_str.should == "StandardError"
    end
  end
  
end

