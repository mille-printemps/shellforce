# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ShellForce::Rest do
  
  it "executes a block and returns its result and response time" do

    method = lambda {|a,b,c| return {}, a+b+c}
    
    result = ShellForce::Rest.request("a", "b", "c") do |a, b, c|
      method.call(a,b,c)
    end

    result[1].should == "abc"
    result[2].zero?.should == false
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

