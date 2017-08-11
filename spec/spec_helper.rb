require 'rspec'
require 'rspec/expectations'
require 'rack/test'

require_relative '../server'
require_relative '../whitelister'

include Rack::Test::Methods

ENV['RACK_ENV'] = 'test'

def app
  Sinatra::Base
end

