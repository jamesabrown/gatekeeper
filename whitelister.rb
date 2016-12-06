require 'aws-sdk'

class Whitelister
  attr_reader :region, :sg_id, :timestamp
  
  def initialize(region, sg_id)
    @region = region
    @sg_id = sg_id
    @timestamp = Time.now.to_i
  end
  
  def client
    @client ||= Aws::EC2::Client.new(region: region)
  end
  
  def sg_query
    @sg ||= Aws::EC2::SecurityGroup.new(sg_id)
  end
  
  def add_ip(user_ip)
    client.authorize_security_group_ingress({
    group_id: sg_id,
    ip_protocol: "-1",
    cidr_ip: "#{user_ip}/32"
    })
  end
  
  def add_tag(user_ip)
    client.create_tags(
      resources: [sg_id],
      tags: [
        {
          key: user_ip, 
          value: timestamp.to_s
        } 
      ]
    )
  end
  
  def authorize_ip(user_ip)
    add_ip(user_ip)
    add_tag(user_ip)
  end
  
  def list_tags
    sg_query.tags
  end
  
  def expire
    list_tags.delete_if{ |t| t.key == "Name" }.each do |x|
      if Time.now.to_i > x.value.to_i + 3600*24*2 
        puts "Removing #{x.key} rule"
        remove_ip(x.key)
        puts "Removing #{x.key} tag" 
        remove_tag(x.key, x.value) 
      else
        puts "#{x.key} not being expired"
      end
    end
  end
  
  def get_tags(user_ip)
    entry = sg_query.tags
    entry.find { |s| s.key == "#{user_ip}/32" }
  end
  
  def remove_ip(user_ip)
    client.revoke_security_group_ingress(
    group_id: sg_id,
    ip_protocol: "-1",
    cidr_ip: "#{user_ip}/32"
    )  
  end
  
  def remove_tag(user_ip, timestamp)
    client.delete_tags({
      resources: [sg_id],
      tags: [
        {
          key: user_ip, 
          value: get_tags(user_ip)
        }
      ]
    })  
  end
end
