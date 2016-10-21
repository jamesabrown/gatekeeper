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
	client.create_tags({
	  resources: [sg_id],
	  tags: [
		{
		  key: user_ip, 
		  value: timestamp.to_s
		} 
	  ]
	})
  end
  
  def authorize_ip(user_ip)
    add_ip(user_ip)
    add_tag(user_ip)
  end
  
  def list_tags
    sg_query.tags
  end
  
  def get_tags(user_ip)
    entry = sg_query.tags
    entry.find { |s| s.key == "#{user_ip}/32" }
  end
  
  def expire_entry
    tag_time = get_tags.value
    now = Time.now.to_i
    tag_expire = tag_time.to_i + 3600*24*14
    if now > tag_expire
      puts "Expiring #{user_ip} rule"
      remove_ip
      remove_tag
    else
      puts "Nothing to expire"
    end
  end
  
  def remove_ip(user_ip)
    client.revoke_security_group_ingress({
	group_id: sg_id,
	ip_protocol: "-1",
	cidr_ip: user_ip
    })  
  end
  
  def remove_tag(user_ip)
	client.delete_tags({
	  resources: [sg_id],
	  tags: [
		{
		  key: user_ip, 
		  value: get_tags.value
		}
	  ]
	})  
  end
end
