require 'rufus-scheduler'
require_relative './whitelister.rb'

scheduler = Rufus::Scheduler.new
logger = Logger.new(STDOUT)

if !ENV['AWS_REGION'].nil? && !ENV['GK_SGID'].nil?
  logger.debug 'ENV variables present, starting scheduler.'
  scheduler.every '2h' do
    logger.debug 'Running whitelister.expire...'
    whitelister = Whitelister.new(ENV['AWS_REGION'], ENV['GK_SGID'])
    whitelister.expire
  end
else
  logger.warn 'Missing ENV variables...'
end