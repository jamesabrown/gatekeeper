# frozen_string_literal: true

# gate_keeper.rb
require 'logger'
require 'sinatra/base'
require './whitelister.rb'
require 'pry-remote'

class GateKeeper < Sinatra::Base
  attr_reader :security_group, :auth_token, :request_payload, :logger, :whitelister
  set :dump_errors, false
  set :raise_errors, true
  set :show_exceptions, false
  set :bind, '0.0.0.0'

  before do
    check_if_security_group_exists
    check_if_auth_token_exists
    error 401 unless request.env['HTTP_KEY'] == auth_token
  end

  before '/whitelist' do
    retrieve_input!
  end

  get '/' do
    'What are we adding to the whitelist?'
  end

  post '/whitelist' do
    user_ip = request_payload['ip']
    user = request_payload['username']

    if !user.nil? && !user_ip.nil?
      whitelister.authorize_ip(user_ip)
      logger.info('user ' + user + ' has registered ip: ' + user_ip)
      content_type :json
      { :status => 200, :message => 'success' }.to_json
    else
      logger.info('invalid request')
      content_type :json
      status 500
      body ({ :status => 500, :message => 'failure' }.to_json)
    end
  end

  post '/expire' do
    whitelister.expire
    200
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def whitelister
    @whitelister ||= Whitelister.new(ENV['AWS_REGION'], security_group)
  end

  def retrieve_input!
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end

  def check_if_security_group_exists
    unless defined?(@security_group)
      if ENV['GK_SGID']
        @security_group = ENV['GK_SGID']
      else
        raise('GK_SGID must be set')
      end
    end
    @security_group
  end

  def check_if_auth_token_exists
    unless defined?(@auth_token)
      if ENV['GK_AUTH_TOKEN']
        @auth_token = ENV['GK_AUTH_TOKEN']
      else
        raise('GK_AUTH_TOKEN must be set')
      end
    end
    @auth_token
  end
end
