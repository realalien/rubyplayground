#encoding:UTF-8

require 'pp'
require 'mongoid'


DATABASE_NAME = "edu_mining"
edu_officers_db  = "edu_officers_db"
# TODO: not a nice place to put the configuration
Mongoid.configure do |config|
    name = DATABASE_NAME
    host = "127.0.0.1"
    port = 27017
    
    config.allow_dynamic_fields = true
    config.database = Mongo::Connection.new.db(name)
    config.use_utc = true  # in case we retrieve data from international news source
end

class Person
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  field :name, type: String
  #has_and_belongs_to_many :records, :class => InfoPiece
end

class InfoPiece
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  field :text, type: String
  #has_and_belongs_to_many :person 
    
end


