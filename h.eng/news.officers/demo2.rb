#encoding:UTF-8

# Purpose: collect news articles from multiple sources and minding



# section 0.1

require 'pp'
require 'mongoid'

require File.join(File.dirname(__FILE__),"../../news.tool/xinmin_collector.rb")
require File.join(File.dirname(__FILE__),"../../news.tool/util.rb")



DATABASE_NAME = "news_mining"
xinmin_daily  = "xinmin_daily"
# TODO: not a nice place to put the configuration
Mongoid.configure do |config|
    name = DATABASE_NAME
    host = "127.0.0.1"
    port = 27017
    
    config.allow_dynamic_fields = true
    config.database = Mongo::Connection.new.db(name)
    config.use_utc = true  # in case we retrieve data from international news source
end



class XinMinDailyArticles
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
    
end


# TEMP: open class for easier processing 
class String # only in context of  <newspaper, news, headlines>
    
    # TODO: make it more dynamic, by multiple source inclu. news agent websites, political websites, etc
    # TODO: collect the roles from job classification system!
    # NOTE: can be a name refers to a collection of people 
    # NOTE: for demo or simplicity, maintai the array by hands is allowed!
    COMMON_LEADER_ROLES = ['领导','书记', '秘书长', '同志'] 
    
    def has_gov_leaders?
        r = Regexp.new(COMMON_LEADER_ROLES.join("|"))
        if self.scan(r).size > 0
            return true
        else
            return false
        end
    end
    
    
    # NOTE: logics should be evaluated throught self defined methods
    # NOTE: sequence of methods for criteria is crucial, in the same way like java nlp! So persist to find more intelligent ways after some statistics!
    # TODO:need persistence for later traceback
    def follow_criterias?(methods)
        all_pass = true
        if (not methods.is_a? Array) or methods.size < 0
           return false 
        else
            for m  in methods
                if self.class.method_defined? m
                    # evaluate 
                    all_pass &&= self.send(m) 
                    return all_pass if not all_pass #break if one not pass
                else
                    puts "[Error] #{m} method is not defined!"
                    return false # fail criteria not defined
                end
            end
            return all_pass
        end
    end    
    
    
    
end

require 'ostruct'



module XinMinToolsets
    # Q: how to open String class and encasulate it into a module?
    
    
    def sentences_with_people_names(str, criterias)
        ss = []
        # NOTE: would array#inject tastes better?
        candidates = str.split(%r{；|。”|。}).collect do |s|
            ss << s if s.follow_criterias? criterias
        end
    end
end


# ------------------------------------------------------------------------------------

if  __FILE__ == $0

=begin
 
# 0.1 Setup local database storage for one news agent!

# TODO: create different db for different news agents, it might be easier(less data come&forth) when mining one news agent.
# TODO: make it possible to general the functionalities of a tool in order to process for another news agent
# TODO: for easier date aggregate, once I saw a stackoverflow page on that!
# RESEARCH: how to create a solr search based on multiple databases?

    
    # ------------  test 1: collect articles
    # setup
    db  = Mongo::Connection.new.db(DATABASE_NAME)
    wl = db.collection(xinmin_daily)  # weibo_local
    #CREAT INDEX if necessary
    
    # grab index
    toc = XinminDailyCollector.daily_news_links(DateTime.new(2013,1,16))
    # retrieve and store  TEMP: only "要闻" during test, SUG: create filtering wrapper around #collect
    toc['pages_links'].collect{|page| page if page['page_title'] =~ /要闻/ }.each do |page|
        puts "----------  #{page['page_title']}  ---------"
        
        page['articles_links'].each do |art|
            puts "Retrieving #{art['article_title']} : #{art['article_link']}"
            
            raw = WebPageTool.retrieve_content(art['article_link'])
            art['text'] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
            pp art
            puts "-------------------------------"
            
            a = XinMinDailyArticles.new(JSON.parse(art.to_json) )
            a.save!
        end
        # TODO: fix-me
        #undefined method `[]' for nil:NilClass (NoMethodError)        from demo2.rb:99:in `each' from demo2.rb 99:in `<main>'
    end
=end    
    
    
    


# 1.0 create listener for regular grabbing


 
 
# 2.0 text mining, count characters repeats

    # ---------------  test 1, find potential name

=begin
    a = "市委副书记殷一璀主持会议，市委常委、政法委书记丁薛祥作工作报告。"
    puts "#{a} has_gov_leaders? \n... #{a.has_gov_leaders?}"
    b = "切实加强政法队伍建设，真正当好中国特色社会主义事业的建设者和捍卫者。"
    puts "#{b} has_gov_leaders?\n ... #{b.has_gov_leaders?}"
    
    puts "evaluting sentence by [has_gov_leaders?,....]"
    puts "a.fulfill?  ... #{a.follow_criterias?(['has_gov_leaders?'])}"
    puts "a.fulfill? w ... #{a.follow_criterias?(['has_gov_leaders'])}"
    puts "a.fulfill?  ... #{a.follow_criterias?(['has_not_defined?'])}"
    puts "-------------------"
=end
    
    
=begin 
=end
    
    puts "Starting..."
    a = XinMinDailyArticles.find("id"=> "50f7b3aef1ce4029df000008").first
 
    if a
       pp a
    else
       puts "Not found."
    end
 
end