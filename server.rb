# server.rb
require 'sinatra'
require './whitelister.rb'
require 'pry-remote'

set :bind, '0.0.0.0'

SECURITY_GROUP = ENV['GK_SGID'] or raise 'GK_SGID must be set'
AUTH_TOKEN = ENV['GK_AUTH_TOKEN'] or raise 'GK_AUTH_TOKEN must be set'


before do
  error 401 unless request.env['HTTP_KEY'] == AUTH_TOKEN
end

get '/' do
  'What are we adding to the whitelist?'
end

post '/whitelist/:ip' do
  user_ip = params[:ip]
  w = Whitelister.new(ENV['AWS_REGION'], SECURITY_GROUP)
  w.authorize_ip(user_ip)
  200
end

post '/expire/' do
  w = Whitelister.new(ENV['AWS_REGION'], SECURITY_GROUP)
  w.expire
  200
end
