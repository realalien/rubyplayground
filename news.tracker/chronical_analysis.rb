#encoding: UTF-8

require 'mechanize' 
require 'couch_potato'  # because we can write view(design doc) in ruby.


# ----- General Ideas ------
# STEP: collect many of news for one of the industries from one or more authentic/credible news agents, store them in a nosql db for analysis. (  should search tagged/analysed values, raw data is only for referencing, )
# STEP: find the numbers(in the context) have chronical series, and construct a table for graphing, compare with other research


CouchPotato::Config.database_name = 'news_track_chronical'


class NewsPiece
  include CouchPotato::Persistence
    
  
end



if __FILE__ == $0
    
    
end


