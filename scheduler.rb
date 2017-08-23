require 'rufus-scheduler'
require_relative './whitelister.rb'

scheduler = Rufus::Scheduler.new
logger = Logger.new(STDOUT)

$stdout.sync = true

if !ENV['AWS_REGION'].nil? && !ENV['GK_SGID'].nil? && ENV['RACK_ENV'] != 'test'
  logger.debug 'ENV variables present, starting scheduler.'
  scheduler.every '2h' do
  logger.debug 'Running whitelister.expire...'
  whitelister = Whitelister.new(ENV['AWS_REGION'], ENV['GK_SGID'])
  whitelister.expire
  end
else
  logger.warn 'Missing ENV variables or in test environment. Not running the scheduler'
end
