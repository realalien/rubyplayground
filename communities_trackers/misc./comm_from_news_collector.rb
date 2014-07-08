#encoding: UTF-8


# Purpose:
# * feeding the database of communities from news source text analysing
# * this demo can also be used to pinpoint the news those of which contains news of specific communities.


# How-to:
# * use news.tool project for data grabing and processing.



# Note:
#
# 2013.8.21
# * TIP: As it requires too much efforts to do the NER, it looks easier to use other location services(e.g. ddmap, baidu reverse geo-code API, etc) to create a dictionary. And then to parse the news for community
# * TIP: http://goo.gl/PvoFKq page has detailed info about a specific community. TODO: detailed study and use info crossing to digging.


if __FILE__ == $0
    
    
    # find if daily news has sth. about the specific communities.
    require File.join(File.dirname(__FILE__), "../../news.tool/xinmin_analyst.rb" )
    puts "Start ...."
    
=begin
    # e.g. quick search throught one day of news, to be specific, Xinmin Daily
 
    util_daily_news_on_keyword(DateTime.new(2013,5,20), DateTime.new(2013,8,20), ['小区','社区','街道', '苑', '坊', '物业'], true)
    puts "Done."
 
=end
    require 'date'
    util_daily_news_on_keyword(DateTime.new(2014,7,7),nil, ['小区','社区','街道', '苑', '坊', '物业'], true)
    puts "Done."
    
    
    
    # extend: create a dictionary for ner search
    
    
    
    
    # extend: research on workflow of community info processing,
    # --> find new one,
    # --> cross checking on several websites,
    # --> linking more related info from web search,
    # --> scrutinize each community by various tools based on community research or any kind of sociology study.
    
    
    
    # by-prod: it's impossible to search all the communities(or names of real estate) from news articles. Therefore, use road name or other info to pindown the area, then use categorized data(from LBS service websites) for regex process.
    # see also: comm_from_ddmap_collector.rb
    
    
    
    
end











