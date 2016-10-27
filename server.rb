# server.rb
require 'sinatra'
require './whitelister.rb'

set :bind, '0.0.0.0'

security_group = ENV['GK_SGID'] || 'sg-XXX' 
auth_token = ENV['GK_AUTH_TOKEN']

before do
  error 401 unless params[:key] == auth_token
end

get '/' do
  'What are we adding to the whitelist?'
end

post '/whitelist/:ip' do
  user_ip = params[:ip]
  w = Whitelister.new('us-east-1', security_group)
  w.authorize_ip(user_ip)
end
