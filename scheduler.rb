require 'rufus-scheduler'
require 'logger'

require_relative './whitelister'

class GateKeeperScheduler
  attr_reader :logger, :scheduler, :whitelister

  def self.run
    if !ENV['AWS_REGION'].nil? && !ENV['GK_SGID'].nil? && ENV['RACK_ENV'] != 'test'
      logger.debug 'ENV variables present, starting scheduler.'
      scheduler.every '2h' do
      logger.debug 'Running whitelister.expire...'
      whitelister = Whitelister.new(ENV['AWS_REGION'], ENV['GK_SGID'])
      whitelister.expire
    end
    else
      logger.warn 'Missing ENV variables or you are in a test environment. Not running the scheduler'
    end
  end

  private

  def self.scheduler
    @scheduler ||= Rufus::Scheduler.new
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
    if ENV['RACK_ENV'] == 'production'
      logger.level = Logger::WARN
    end
    @logger
  end

  def self.whitelister
    @whitelister ||= Whitelister.new(ENV['AWS_REGION'], ENV['GK_SGID'])
  end
end
