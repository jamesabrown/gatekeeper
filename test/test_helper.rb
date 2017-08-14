# test_helper.rb
require 'rspec'
require 'rack/test'
require 'sinatra'

ENV['RACK_ENV'] = 'test'
require File.expand_path '../../server.rb', __FILE__
RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end
