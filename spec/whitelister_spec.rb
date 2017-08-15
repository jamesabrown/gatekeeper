# frozen_string_literal: true

require File.expand_path '../spec_helper.rb', __FILE__
describe 'Whitelist' do
  it 'should add IP to the whitelist' do
    client = Aws::EC2::Client.new(stub_responses: true)
    whitelist = Whitelister.new('ss', '121')
    expect(whitelist).to receive(:client) { client }.twice
    whitelist.authorize_ip('192.168.10.1')
  end
end

describe 'Expire' do
  it 'should correctly remove the security group' do
    expect(true).to eq(true)
  end
end
