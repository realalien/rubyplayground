#encoding:UTF-8

require 'pp'
require 'mongoid'

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


