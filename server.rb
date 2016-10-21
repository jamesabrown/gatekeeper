# server.rb
require 'sinatra'
require './whitelister.rb'

security_group = 'sg-XX'

get '/' do
  'What are we adding to the whitelist?'
end

post '/whitelist/:ip' do
  user_ip = params[:ip]
  w = Whitelister.new('us-east-1', security_group)
  w.authorize_ip(user_ip)
end
