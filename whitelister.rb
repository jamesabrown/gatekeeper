require 'aws-sdk'
require 'logger'
require 'pry-remote'

class Whitelister
  attr_reader :region, :sg_id, :logger

  def initialize(region, sg_id)
    @region = region
    @sg_id = sg_id
  end

  def timestamp
    Time.now.to_i
  end

  def expire
    list_tags.delete_if { |t| t.key == 'Name' }.each do |x|
      if Time.now.to_i > x.value.to_i + ENV['EXPIRE_TIME'].to_i
        logger.info "Removing #{x.key} rule"
        remove_ip(x.key)
        logger.info  "Removing #{x.key} tag"
        remove_tag(x.key, x.value)
      else
        logger.info "#{x.key} not being expired"
      end
    end
  end

  def authorize_ip(user_ip)
    add_ip(user_ip)
    add_tag(user_ip)
  rescue Aws::EC2::Errors::InvalidPermissionDuplicate
    logger.info(' duplicate ip ' + user_ip)
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT)
    if ENV['RACK_ENV'] == 'production'
      logger.level = Logger::WARN
    end
    @logger
  end

  def client
    @client ||= Aws::EC2::Client.new(region: region)
  end

  def sg_query
    @sg ||= Aws::EC2::SecurityGroup.new(sg_id)
  end

  def add_ip(user_ip)
    client.authorize_security_group_ingress(group_id: sg_id,
                                            ip_protocol: '-1',
                                            cidr_ip: "#{user_ip}/32")
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

  def list_tags
    sg_query.tags
  end

  def get_tags(user_ip)
    entry = list_tags
    entry.find { |s| s.key == "#{user_ip}/32" }
  end

  def remove_ip(user_ip)
    client.revoke_security_group_ingress(
      group_id: sg_id,
      ip_protocol: '-1',
      cidr_ip: "#{user_ip}/32"
    )
  end

  def remove_tag(user_ip, _timestamp)
    client.delete_tags(resources: [sg_id],
                       tags: [
                         {
                           key: user_ip,
                           value: get_tags(user_ip)
                         }
                       ])
  end
end
