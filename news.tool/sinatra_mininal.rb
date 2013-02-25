#encoding:UTF-8

require 'sinatra'
require 'date'

require File.join(File.dirname(__FILE__),"xinmin_collector.rb")

# Q: how to redirect? A: 
get '/xinmin/' do 
     redirect "/xinmin/#{Date.today.strftime('%F')}"
end

get '/xinmin/:date' do |date|
    # "Received:  #{params[:date]}!"
    
    # TODO: sanity check for date
    yr,m,d = date.split('-')
    tpc = XinminDailyCollector.daily_news_toc_reload(yr,m,d) # TODO: should retrieved from nosql
    [toc
end







