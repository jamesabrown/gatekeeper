require 'coveralls'
Coveralls.wear!

require_relative  '../gate_keeper.rb'

require 'rspec'
require 'rack/test'
require 'sinatra'
require 'timecop'

module RSpecMixin
  include Rack::Test::Methods

  def app
    GateKeeper
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
