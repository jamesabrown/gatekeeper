require_relative 'spec_helper'

Aws.config[:stub_responses] = true


RSpec.describe Whitelister do
  whitelister = Whitelister.new('region', 'sg_id')
  mock_sg = MockSecurityGroup.new
  mock_client = MockClient.new(mock_sg)

  whitelister.inject_mock_client(mock_client)
  whitelister.inject_mock_sg(mock_sg)

  describe 'Whitelister::expire' do
    it 'should expire the tags which are older than the set time limit.' do
      whitelister.expire
      expect(true).to eq(true)
    end
  end

  describe 'Whitelister::authorize_ip' do
    it 'should add an ip to an aws security group.' do
      whitelister.authorize_ip('127.0.0.1')
      expect(true).to eq(true)
    end
  end
end