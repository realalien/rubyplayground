# Q: how to authorize for a desktop app? 

# REF: oauth for desktop app 
#      http://pragtob.wordpress.com/tag/desktop-application/

require 'oauth'
require 'launchy'


%w(rubygems bundler).each { |dependency| require dependency }
Bundler.setup
%w(haml oauth sass json weibo).each { |dependency| require dependency }

#enable :sessions

Weibo::Config.api_key = "3422703718"
Weibo::Config.api_secret = "56b821f7588cf3987878b7d5beed1c32"

oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
request_token =  oauth.consumer.get_request_token


Launchy.open request_token.authorize_url
puts "Please authorize the app to have access to your Twitter account. A pincode will be displayed to you, please enter it here:"

pincode = gets.chomp

#timeline = Weibo::Base.new(oauth).friends_timeline
#put timeline
