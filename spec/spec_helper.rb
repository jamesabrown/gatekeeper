require 'rspec'
require 'rspec/expectations'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
ENV['GK_SGID'] = '007'
ENV['GK_AUTH_TOKEN'] = '7789'
ENV['EXPIRE_TIME'] = '5000'

require_relative '../server'
require_relative '../whitelister'

include Rack::Test::Methods

Aws.config[:stub_responses] = true

def app
  Sinatra::Base
end

class MockSecurityGroup
  attr_reader :tags, :ips

  def initialize
    @tags = []
    @ips = []
  end

  def add_tag(sg_id, key, value)
    @tags << MockTag.new(sg_id, key, value)
  end

  def delete_tag(sg_id, key, value)
    @tags.delete_if { |tag| tag.sg_id == sg_id && tag.key == key && tag.value == value }
  end

  def add_ip(group_id, ip_protocol, cidr_ip)
    @ips << MockIp.new(group_id, ip_protocol, cidr_ip)
  end

  def remove_ip(group_id, ip_protocol, cidr_ip)
    @ips.delete_if{ |ip| ip.group_id == group_id && ip.ip_protocol == ip_protocol && ip.cidr_ip == cidr_ip}
  end
end

class MockIp
  attr_reader :group_id, :ip_protocol, :cidr_ip

  def initialize(group_id, ip_protocol, cidr_ip)
    @group_id = group_id
    @ip_protocol = ip_protocol
    @cidr_ip = cidr_ip
  end
end

class MockTag
  attr_reader :sg_id, :key, :value

  def initialize(sg_id, key, value)
    @key = key
    @value = value
    @sg_id = sg_id
  end
end

class MockClient

  def initialize(mock_sg)
    @sg = mock_sg
  end

  def authorize_security_group_ingress(hash_obj)
    @sg.add_ip(hash_obj[:group_id], hash_obj[:ip_protocol], hash_obj[:cidr_ip])
  end

  def revoke_security_group_ingress(hash_obj)
    @sg.remove_ip(hash_obj.group_id, hash_obj.ip_protocol, hash_obj.cidr_ip)
  end

  def create_tags(hash_obj)
    @sg.add_tag(hash_obj[:resources][0], hash_obj[:tags][0][:key], hash_obj[:tags][0][:value])
  end

  def delete_tags(hash_obj)
    @sg.delete_tag(hash_obj.resources[0], hash_obj.tags[0]['key'], hash_obj.tags[0]['value'])
  end
end

class Whitelister
  def inject_mock_client(mock_client)
    @client = mock_client
  end

  def inject_mock_sg(sg_mock)
    @sg = sg_mock
  end
end
