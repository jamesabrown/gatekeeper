# server.rb
require 'sinatra'
require './whitelister.rb'

set :bind, '0.0.0.0'

SECURITY_GROUP = ENV['GK_SGID'] or raise "GK_SGID must be set" 
AUTH_TOKEN = ENV['GK_AUTH_TOKEN'] or raise "GK_AUTH_TOKEN must be set"

before do
  error 401 unless request.env['HTTP_KEY'] == auth_token
end

get '/' do
  'What are we adding to the whitelist?'
end

post '/whitelist/:ip' do
  user_ip = params[:ip]
  w = Whitelister.new('us-east-1', security_group)
  w.authorize_ip(user_ip)
end

post '/expire/' do
  w = Whitelister.new('us-east-1', security_group)
  w.expire
end
