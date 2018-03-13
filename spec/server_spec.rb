# frozen_string_literal: true

require_relative 'spec_helper'
require 'json'

class MockGeocoderEntry
  attr_reader :data
  def initialize(data)
    @data = data
  end
end

describe 'Missing ENV variables' do
  ['/', '/whitelist/1', '/expire', 'random'].each do |path|
    it "return an error if GK_SGID is not provided for path #{path}" do
      expect { get path }.to raise_error('GK_SGID must be set')
    end
  end

  ['/', '/whitelist/1', '/expire', 'random'].each do |path|
    it "return an error if GK_AUTH_TOKEN is not provided for path #{path}" do
      ENV['GK_SGID'] = 'GK_SGID'
      expect { get path }.to raise_error('GK_AUTH_TOKEN must be set')
    end
  end
end

describe 'Authorized access without ALLOWED_COUNTRIES' do
  before :each do
    ENV['GK_SGID'] = 'GK_SGID'
    ENV['GK_AUTH_TOKEN'] = 'GK_AUTH_TOKEN'
  end

  it 'should return the correct response if the ENV variables are set' do
    get '/', nil, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('What are we adding to the whitelist?')
  end

  it 'should return a json obj with status code of 200 and a message if the correct body with a correct ip was posted.' do
    expect_any_instance_of(Whitelister).to receive(:authorize_ip)
    post '/whitelist', { 'ip' => '127.0.0.1', 'username' => 'user' }.to_json, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    result = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(result['status']).to eq(200)
    expect(result['message']).to eq('success')
  end

  it 'should return a json obj with status code of 500 and a message if the correct body with an incorrect ip was posted.' do
    post '/whitelist', { 'ip' => '127.0.0.fff', 'username' => 'user' }.to_json, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    result = JSON.parse(last_response.body)
    expect(last_response.status).to eq(500)
    expect(result['status']).to eq(500)
    expect(result['message']).to eq('failure')
  end

  it 'should return a json obj with status code of 500 and a message if the body does not exist.' do
    post '/whitelist', {}.to_json, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    result = JSON.parse(last_response.body)
    expect(last_response.status).to eq(500)
    expect(result['status']).to eq(500)
    expect(result['message']).to eq('failure')
  end

  it 'should return a json obj with status code of 500 and a message if the body does not have the proper values.' do
    post '/whitelist', { 'not_ip' => '127.0.0.1', 'not_username' => 'user' }.to_json, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    result = JSON.parse(last_response.body)
    expect(last_response.status).to eq(500)
    expect(result['status']).to eq(500)
    expect(result['message']).to eq('failure')
  end

  it 'should return a json obj with status code of 500 and a message if the IP address is invalid.' do
    post '/whitelist', { 'ip' => 'Invlaid', 'username' => 'user' }.to_json, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    result = JSON.parse(last_response.body)
    expect(last_response.status).to eq(500)
    expect(result['status']).to eq(500)
    expect(result['message']).to eq('failure')
  end
end

describe 'Unauthorized access' do
  before :each do
    ENV['GK_SGID'] = 'GK_SGID'
    ENV['GK_AUTH_TOKEN'] = 'GK_AUTH_TOKEN'
  end

  it 'should return a 401 if the token provided does not match.' do
    get '/', nil, 'HTTP_KEY' => 'INVALID_TOKEN'
    expect(last_response.status).to eq(401)
  end

  it 'should not call authorize_ip if the token provided does not match.' do
    expect(app).to receive(:authorize_ip).exactly(0).times
    body = { 'username' => 'user', 'ip' => '127.0.0.1' }
    post '/whitelist', body, 'HTTP_KEY' => 'INVALID_TOKEN'
    expect(last_response.status).to eq(401)
  end
end
