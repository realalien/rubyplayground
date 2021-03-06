#encoding:UTF-8

require 'sinatra'
require 'date'
require 'json'

#require File.join(File.dirname(__FILE__),"xinmin_collector.rb")


#class XinMinServer < Sinatra::Base

set :run, true
set :server, %w[thin mongrel webrick]

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
    # -- simple json without articles content and not from db
    # toc = XinminDailyCollector.daily_news_toc_reload(yr.to_i,m.to_i,d.to_i) # TODO: should retrieved from nosql
    # toc.to_json
    
	require File.join(File.dirname(__FILE__),"xinmin_collector.rb")
    #XinminDailyCollector.save_daily_news_to_db(yr,m,d,force_reload_articles=false, get_content=true, verbose=false )
    ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr.to_i,m.to_i,d.to_i)) #.with_seq_no(3)
    #ps.all.to_json #(:include => :articles)
	ps.all.to_json
end



#end # of class



