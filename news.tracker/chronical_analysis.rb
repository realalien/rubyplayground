#encoding: UTF-8

require 'mechanize' 
require 'couch_potato'  # because we can write view(design doc) in ruby.


# ----- General Ideas ------
# STEP: collect many of news for one of the industries from one or more authentic/credible news agents, store them in a nosql db for analysis. (  should search tagged/analysed values, raw data is only for referencing, )
# STEP: find the numbers(in the context) have chronical series, and construct a table for graphing, compare with other research


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
  view :all, :key => [:news_agent_name, :]
  
  
end


# --------------------------------------------------------------------------------


require File.join(File.dirname(__FILE__),"eeo_number_collector.rb")




if __FILE__ == $0
    
=begin    
  # test of couchdb storage
  link = "http://www.eeo.com.cn/2012/0611/228081.shtml"
  page = retrieve_content(link)
  title, content, raw = eeo_title_and_content(page)
  
  # TODO: abstract into a common interface of speicific grabbing tool
  a = NewsPiece.new :title => title, :content => content, :raw_page => raw, :news_agent_name => "eeo", :link => link
  
  CouchPotato.database.save_document a
=end
  
  
  # retrieve test
  # Q: what if error occurs? A:
  
 
 
  
  # test of newly added property after some data has been stored.  
  
end


