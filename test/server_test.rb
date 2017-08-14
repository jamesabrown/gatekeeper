require File.expand_path '../test_helper.rb', __FILE__
require 'pry'

describe 'my example app' do
  before :each do
    p 'sssss'
    ENV['GK_SGID'] = 'GK_SGID'
    ENV['GK_AUTH_TOKEN'] = 'GK_AUTH_TOKEN'
  end
  it 'should return the correct response if the ENV variables are set' do
    get '/', {}, {'rack.env' => { HTTP_KEY:'HTTP_KEY'}} 
    expect(last_response).to be_ok
    expect(last_response.body).to eq('What are we adding to the whitelist?')
  end
end
