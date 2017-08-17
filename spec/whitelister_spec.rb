# frozen_string_literal: true

class MockTag
  attr_reader :key, :value
  def initialize(key,value)
    @key = key
    @value = value
  end
end

expired_tag = MockTag.new('127.0.0.1', (Time.now.to_i - 50000).to_s)
fresh_tag = MockTag.new('127.0.0.2', (Time.now.to_i + 20000).to_s)

require File.expand_path '../spec_helper.rb', __FILE__
describe 'Whitelist' do
  it 'should add IP to the whitelist' do
    client = Aws::EC2::Client.new(stub_responses: true)
    whitelist = Whitelister.new('region', '121')

    expect(whitelist).to receive(:client) { client }.twice
    expect(client).to receive(:authorize_security_group_ingress).with({:group_id => '121', :ip_protocol => '-1', :cidr_ip => '192.168.10.1/32'})
    expect(client).to receive(:create_tags).with({:resources => ['121'], :tags => [{:key => '192.168.10.1', :value => Time.now.to_i.to_s }]})

    whitelist.authorize_ip('192.168.10.1')
  end
end

describe 'Expire' do
  before :each do
    ENV['EXPIRE_TIME'] = '10'
  end
  it 'should correctly remove the security group entries that have expired tags.' do
    client = Aws::EC2::Client.new(stub_responses: true)
    whitelist = Whitelister.new('region', '121')

    allow(whitelist).to receive(:list_tags).and_return([expired_tag, fresh_tag])
    expect(whitelist).to receive(:client) { client }.exactly(2).times
    expect(client).to receive(:revoke_security_group_ingress).with({:group_id => '121', :ip_protocol => '-1', :cidr_ip => '127.0.0.1/32'})
    expect(client).to receive(:delete_tags).with({:resources => ['121'], :tags => [{:key => '127.0.0.1', :value => nil }]})

    whitelist.expire
  end

  it 'should not remove any security group entries if none exists.' do
    client = Aws::EC2::Client.new(stub_responses: true)
    whitelist = Whitelister.new('region', '121')

    allow(whitelist).to receive(:list_tags).and_return([])
    expect(whitelist).to receive(:client) { client }.exactly(0).times

    whitelist.expire
  end

  it 'should not remove any security group entries if none are expired.' do
    client = Aws::EC2::Client.new(stub_responses: true)
    whitelist = Whitelister.new('region', '121')

    allow(whitelist).to receive(:list_tags).and_return([fresh_tag])
    expect(whitelist).to receive(:client) { client }.exactly(0).times

    whitelist.expire
  end
end
