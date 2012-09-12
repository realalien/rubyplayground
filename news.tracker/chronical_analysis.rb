# encoding: UTF-8

require 'mechanize' 
require 'couch_potato'  # because we can write view(design doc) in ruby.
require 'mongoid'
require 'feedzirra'


# ----- General Ideas ------
# STEP: collect many of news for one of the industries from one or more authentic/credible news agents, store them in a nosql db for analysis. (  should search tagged/analysed values, raw data is only for referencing, )
# STEP: find the numbers(in the context) have chronical series, and construct a table for graphing, compare with other research

# NOTE: 
# * after several web searches and examples in "Mining The Social Web", I assume that the data will be collected and stored in mongoid, for the reason that it's easier for query. But for data analysis, couchdb might be used in that a lot of existing demo can be reused like those on the book mentioned before.

# -------------------------------------------------------------

Mongoid.configure do |config|
    name = "news_tracker_dev"
    host = "localhost"
    port = 27017
    config.database = Mongo::Connection.new.db(name)
end


class NewsArticle
    
    include Mongoid::Document 
    include Mongoid::Timestamps # adds automagic fields created_at, updated_at
    
    field :title, type: String  # 标题
    field :content, type: String  # 文章或网页内容（尽量剔除不需要的内容）
    field :raw_page, type: String  # 原始页面
    
    field :news_agent_name  # 新闻机构
    field :link, type: String   # 链接
   
    
    # VALIDATION
    validates_presence_of :title, :content, :raw_page
    validates_presence_of :news_agent_name, :link
    
    validates_uniqueness_of :title, :scope => [:news_agent_name]  # 同一个机构不收录同名文章(避免重复录入) TODO: potential bug, should include aricle publishing date.
    validates_inclusion_of :news_agent_name, :in => ['eeo' ] # NOTE: even in dev, sources are limited. # Later, we may register for expression to get the list of values allowed.
    
end


# supposed to monitor/mgmt a data key 
class NewsAnalyser
  
end

# IDEA: is it possible to create a module to read the source code's annotation to report implementation/design detail, like EeoCollector#describe gives "blah, ..."
class EeoCollector
    
  # retrieve, process and store
  def self.collect(url_str)
    page = self.retrieve_content(url_str)
    if page
      title, content, raw = self.eeo_title_and_content(page)
      puts "#{title}\n" ; puts "#{content}\n" ; puts "#{raw}"
    else
      puts "[Error] Failed to grab page from url #{url_str}"
    end

    # TODO: refactor out
    if title && content && raw  # make sure every thing exists
      begin 
        na = NewsArticle.create! :title=> title, :content=> content, :raw_page => raw, :news_agent_name => "eeo", :link => url_str
        puts "[Info] Data saved!"
      rescue  => e
        puts "[Error] failed to save data, error:"
        puts e.message
        puts e.backtrace.join("\n")
      end
    else
      puts "[Error] Failed to insert data of url #{url_str},\ntitle: #{title}\ncontent: #{content}\nraw: #{raw}"
    end
  end

  #TODO: there are much useful data(e.g. link meta data, probably for SEO, so).
  def self.retrieve_content(url)
    begin
      m = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      page = m.get(url)
    rescue => e 
      puts "[Error] retrieving #{url} "; puts e.message; puts e.backtrace
      page = nil
    ensure
      #puts page.inspect ; #puts page.content
      return page
    end
  end


  # process after retrieving the raw page, return raw title and raw content(with html tag)
  # Q: how to deal with article that of regular updates?
  # A: 
  # TODO:  unforseeable page element id change handling
  def self.eeo_title_and_content(page)
      xpath = "//div[@id='text_content']"
      node_set = page.search(xpath)
      
      if node_set && node_set.length > 0 
          #puts node_set[0].inner_text
          return [page.title, node_set[0].inner_text, page.body] #TODO: download the reference js or other files.
      else
          return [nil,nil,nil]
      end
  end
end


# -------------------------------------------------------------
#  Experimenting of modeling with Couchdb,

# This collect serves:
# * auto detect the title, news content(probably the div element with most text), news_agent_name(probably the 'author' meta info of the page) on arbitrary news source.
# * persist the logic(e.g. the xpath toward the content)
class GeneralCollect

end


  
class NumberAnalyser ; end
class NoteTaker ; end


# -------------------------------------------------------------
#  Experimenting of modeling with Couchdb,


CouchPotato::Config.database_name = 'news_track_chronical'

=begin
 
 # test bed of how we should model the data
 
# self made 
class Collector
 
 
end
 
 
# modeled after xxxx system
 
 
 
=end


# NOTE:IDEA: suggested by 'Many-to-many relationships in CouchDB or MongoDB'http://goo.gl/N526n, it looks like that we need to keep all the raw data as much as possible(read again to confirm?!)

# Modeling of one piece of information from one source(news agents), and to differentiate with other information modelings, this class is suppposed to be used in collecting news articles with dozens of statistic numbers, people, organizations, which can be used for tracking.

# Q: what if a source(news agent) has multiple versions(e.g. paper media, online media which is updatable), then how  A:

class NewsPiece
  include CouchPotato::Persistence
    
  # PROPERTIES
  # basic info, probably more in the future
  property :title
  property :content   # clean, TODO: it actually depends on the collector tools' setting or configuration,  
  property :raw_page  # keeps all page meta data which can be reused, :content is supposed to be clean articles for text analysing.
  
  
  # collector information
  property :collected_at, :type => Time
  property :collector_description  # IDEA: the name, the commit id on github.
  
  
  # news agent related
  property :news_agent_name  #  it will be nice if we open API of NewsPiece with news agent domain object embedded, much like weibo user containing one latest API, but for storage, it's doesn't seems to look nice, SUG: another documents? Q: how to create model relationships in couchdb in the same way of mongodb? TODO
  property :link   # Q: an array of links, including the original and the distributors? SUG: no, this model is supposed to be a modeling of one piece of information from one source(news agent!)
  
  
  
  # VALIDATION
  validates_presence_of :title, :content, :raw_page
  
  validates_presence_of :news_agent_name, :link
  
  
  # VIEW for search , Q: do I have use lucene to search data indexing and keyword search? A: 
  view :all, :key => [:news_agent_name]
  
  
end

# --------------------------------------------------------------------------------



if __FILE__ == $0
    
=begin    
  # test of couchdb storage
  link = "http://www.eeo.com.cn/2012/0611/228081.shtml"
  page = retrieve_content(link)
  title, content, raw = eeo_title_and_content(page)
  
  # TODO: abstract into a common interface of speicific grabbing tool
  a = NewsPiece.new :title => title, :content => content, :raw_page => raw, :news_agent_name => "eeo", :link => link
  
  CouchPotato.database.save_document a
 
 
 
 # retrieve test
 # Q: what if error occurs? A:
=end
  
  
=begin
  # test of mongodb storage
 
  
=end
    

=begin
     # ============== TEST of regular data crawling  ==============
=end

# NOTE: the Feedzirra is unable to parse eeo's news correctly, TODO: find out why and fix!

url = "http://app.eeo.com.cn/?app=rss&controller=index&action=feed&catid=29"
url = "http://www.eeo.com.cn/finance/rss.xml"  
url = "http://www.google.com/alerts/feeds/09340687053359415747/10888760548232237201"
# fetching a single feed
feed = Feedzirra::Feed.fetch_and_parse(url, 
                                       :on_success => lambda {|feed| puts "aa #{feed.title}" },
                                       :on_failure => lambda {|url, response_code, response_header, response_body| puts response_body })
#puts feed
sleep_interval = 60*5

while true do 
    updated_feed = Feedzirra::Feed.update(feed)
    #puts updated_feed.class
    #puts updated_feed.has_new_entries?
    a = updated_feed.new_entries  # TODO: is it ok when first load the resources?
    if a.size > 0
      puts "Found new #{a.size} entries..."
      a.each do |entry |
        puts "processing ...#{entry.title} ( #{entry.url} )"
          # EeoCollector.collect entry.url
      end
      sleep_interval = 60*5  
    else 
      puts "No new entry found."
      sleep_interval = 60 # check every min
    end
    
    puts "updated at: #{Time.now}"
    sleep sleep_interval
end


    

 
=begin  
  # test of newly added property after some data has been stored.  
  
  if ARGV.size == 1
      EeoCollector.collect ARGV[0]
  else
     puts "[Usage]ruby chronical_analysis.rb <url>" 
  end
=end 
 
end


