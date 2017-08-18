# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require File.expand_path '../../gate_keeper.rb', __FILE__

require 'rspec'
require 'rack/test'
require 'sinatra'


module RSpecMixin
  include Rack::Test::Methods

  def app
    GateKeeper
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
