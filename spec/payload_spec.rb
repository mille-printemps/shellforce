# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ShellForce::Payload do

  it "accepts a file" do
    metadata = '{"Description" : "Test", "Keywords" : "Test", "Name" : "Test"}'
    file = File.new(__FILE__)
    
    data = {:metadata => metadata, :file => file}
    headers = {}
    format = :json

    filename = File.basename(file.path)

    payload = ShellForce::Payload.new(data, headers, format)
    
    payload.headers["Content-Type"].should == "multipart/form-data; boundary=\"#{payload.boundary}\""
    data_set = payload.data.split("--#{payload.boundary}")
    
    if data_set[1].size < data_set[2].size
      metadata_body = data_set[1]
      file_body = data_set[2]
    else
      metadata_body = data_set[2]
      file_body = data_set[1]
    end

    metadata_bodies = metadata_body.split(ShellForce::Payload::NEWLINE)
    file_bodies = file_body.split(ShellForce::Payload::NEWLINE)
    
    data_set.size.should == 4

    metadata_bodies.index("Content-Disposition: form-data; name=\"metadata\";").should_not == nil
    metadata_bodies.index("Content-Type: application/json").should_not == nil
    metadata_bodies.index(metadata).should_not == nil    

    file_bodies.index("Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"").should_not == nil
    file_bodies.index("Content-Type: application/x-ruby").should_not == nil
  end
  
end

