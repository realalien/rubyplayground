

#encoding: UTF-8

require 'rubygems'
require 'mechanize'
require 'uri'

require 'mongo'
require 'mongo_mapper'


require 'geokit'


require 'pp'



$DATABASE_DEV = "lbs4community_dev"
MongoMapper.database = $DATABASE_DEV
#shops =  MongoMapper.database.collection("shops")


class GeoCommunity
    
    include MongoMapper::Document
    
    key :name, String, :required => true

    
end



class 


if __FILE__ == $0
    
    
end

