#encoding:UTF-8

require 'sinatra'
require 'date'
require 'json'

require File.join(File.dirname(__FILE__),"xinmin_collector.rb")

# Q: how to redirect? A: 
get '/xinmin/' do
    if Time.now.hour < 16  # xinmin daily published around 3,4 P.M.
        redirect "/xinmin/#{(Date.today - 1).strftime('%F')}"
    else
        redirect "/xinmin/#{Date.today.strftime('%F')}"
    end
end

get '/xinmin/:date' do |date|
    
    # "Received:  #{params[:date]}!"
    
    # TODO: sanity check for date
    content_type 'application/json', :charset => 'utf-8'
    yr,m,d = date.split('-')
    puts "----------------------------"
    puts yr,m,d
    toc = XinminDailyCollector.daily_news_toc_reload(yr.to_i,m.to_i,d.to_i) # TODO: should retrieved from nosql
    toc.to_json
end







