#encoding:UTF-8


#NOTE: example modeled after the p.50, Mining the Social Web
#NOTE: example dataset(423Mb) http://www.cs.cmu.edu/~enron/enron_mail_20110402.tgz 
#TODO: make it clear about the ruby query view server
#     http://wiki.apache.org/couchdb/View_server
#     https://github.com/candlerb/couchdb_ruby_view
#     https://github.com/mattly/couchdb-ruby-query-server




require 'couchrest' #REF:https://github.com/couchrest/couchrest/wiki/Usage-Overview
require 'json' #REF: http://ruby.about.com/od/tasks/a/The-Json-Gem.htm
#TODO: try out another gem (https://github.com/brianmario/yajl-ruby/) and compare with the one written by Milo!


require '/Users/dhs/zjc/sandbox/couchdb-ruby-query-server/lib/couch_db.rb'

# p.52
def load_json_to_db(json_filename, dbname)
  db = CouchRest.database!("http://127.0.0.1:5984/#{dbname}") 
  content = File.read(json_filename)
  jsons = JSON.parse content
  db.bulk_save(jsons)     

  # TODO: exception handling of file reading, json parsing and couchrest 
end



# p.54
# Q:It looks like there is no easy way to create view from ruby with ruby query server, now I use the couch_potato for exp. 
def view_by_datetime
  CouchDB::Sandbox.safe = true
  CouchDB::View.reset
  request = CouchDB.run( ["add_fun", "lambda {|doc|  emit(doc.created_at, doc) if doc.respond_to? :created_at} "] ) 

  puts request.inspect
  if request
	puts "view created!"
  else
	puts "view not created!"
  end

  puts CouchDB::View::FUNCTIONS.size
  puts CouchDB::View::FUNCTIONS.first


  response = CouchDB.run(["map_doc",   ])

end

#----------------------------------------
#p.54
# use weibo status exmple data to 

require File.join(File.dirname(__FILE__),"../../util.d/weibo_client.rb")
def load_tweets_into_db
 
  user = $client.user_show_by_screen_name "realalien"

  sts = $client.statuses user.id
  partial = sts.items_of_current_page

  #puts partial.collect{|p|p.data }.inspect

  File.open "a.json", "w" do |f|
    f.puts partial.collect{|p|p.data}.to_json
  end

  load_json_to_db("a.json", "couchdb_mbox_test")
end


# NOTE:  couch_potato seems to persist data with extra 'doc.ruby_class', which may cause trouble when the data model changes and other issues, try using 
require 'couch_potato'

# config
CouchPotato::Config.database_name = 'couchdb_mbox_test'

class Stata
  include CouchPotato::Persistence
  view :all, :key => :created_at 
end


# ------------------------


require 'couch_foo'
class Status < CouchFoo::Base

end

if __FILE__ == $0
  
  
  
  #programming use only
  #load_json_to_db("a.json", "couchdb_mbox_test")
  #view_by_datetime



  #load_tweets_into_db
  
  #db = CouchPotato.database
  #puts db.view(Stata.all)
 
  ss = Status.all
  puts ss

 
end


