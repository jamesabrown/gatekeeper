require_relative 'spec_helper'
require_relative '../scheduler'

describe 'GatekeeperScheduler with ENV variables' do
  before do
    ENV['GK_SGID'] = '1234'
    ENV['AWS_REGION'] = 'US-EAST-1'
    ENV['RACK_ENV'] = 'debug'
  end

  it 'Should run rufus scheduler if all ENV variables are present.' do
    expect_any_instance_of(Rufus::Scheduler).to receive(:every) { true }.once
    GateKeeperScheduler.run
  end

  after do
    ENV['GK_SGID'] = nil
    ENV['AWS_REGION'] = nil
    ENV['RACK_ENV'] = nil
  end
end

describe 'GatekeeperScheduler without ENV variables' do
  before do
    ENV['GK_SGID'] = nil
    ENV['AWS_REGION'] = nil
    ENV['RACK_ENV'] = 'test'
  end

  it 'Should not run rufus scheduler if ENV variables are not present.' do
    expect_any_instance_of(Logger).to receive(:warn).with('Missing ENV variables or you are in a test environment. Not running the scheduler').once
    GateKeeperScheduler.run
  end
end
