#encoding:UTF-8


#TODO: freeze the gems for developing, `rvm `


require 'pp'
require 'mongoid'
require File.join(File.dirname(__FILE__),"../wb.bz/util.d/weibo_client.rb")




# -------------------------  play  ------------------------




# -------------------------  non core service  ------------------------

DATABASE_NAME = "sns_accounts"
sns_weibo  = "sns_weibo"
# TODO: not a nice place to put the configuration
Mongoid.configure do |config|
  name = DATABASE_NAME
  host = "localhost"
  port = 27017
  
  config.allow_dynamic_fields = true
  config.database = Mongo::Connection.new.db(name)
  config.use_utc = true  # in case we retrieve data from international news source
end



# NOTE: use gem for clean/changeable data handling rather than enforce a rigid data structure!
# TODO: make sure that there isn't unwanted data caused by mongoid gem or other tools
class WeiboUser
  include Mongoid::Document
  
  include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
end


# -------------------------  trial and error  ------------------------

if __FILE__ == $0

  
  # setup
  db  = Mongo::Connection.new.db(DATABASE_NAME)
  wl = db.collection(sns_weibo)  # weibo_local
  wl.create_index(['_id', 1])
  
  # ----- insert test

=begin
  # a real user from weibo sns
  user_from_weibo_remote = $client.user_show_by_screen_name("李开复")
  pp user_from_weibo_remote.inspect
  # insert and manual check if any unwanted data(e.g. _type_id from tooling)
  user_to_insert = WeiboUser.new( JSON.parse(user_from_weibo_remote.data.to_json) )
  user_to_insert.save!
  pp user_to_insert.inspect
=end
  
  # ----- Improve: insert refind, single entrance for multiple collectors.
  
  
  # ----- find test
=begin
    r = wl.find(:id => "1197161814")  # by_id
    pp r.inspect
    pp r.count
=end    
    
    
  # ----- Improve: find criteria should vary based on some kind of meta info. e.g. from a newspaper website, 'report name' search should be done first.
  
  
  # ----- dulplication avoid handling test
  
  
  
  # ----- replication test for home/office working env chg
  
  
  
end



# REF:

# MongoDB in Three Minutes
# http://kylebanker.com/blog/2009/11/mongodb-in-three-minutes/

