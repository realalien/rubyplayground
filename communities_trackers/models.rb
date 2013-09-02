#encoding: UTF-8

require 'mongoid'
require 'mongoid_geospatial'


require File.join(File.dirname(__FILE__),"const.rb")

# Ref. http://mongoid.org/en/mongoid/docs/documents.html, Custom field serialization

# NOTE: shanghai address level by avenue
#   http://www.shmzj.gov.cn/gb/shmzj/node8/node15/node58/node77/node116/userobject1ai4872.html



class AddressComponent
    include Mongoid::Document
    
    field :province, type: String
    field :city,         type:String
    field :district,     type:String
    field :sub_district, type:String
    field :street_name,  type:String
    field :street_num,   type:String
  
    # validation
    validates_inclusion_of :province,  in: [ $SH_PROVINCE ]
    validates_inclusion_of :city,      in: [ $SH_CITY ]
    validates_inclusion_of :district,  in: $SH_DISTRICTS
    # validation on sub_district
  
    # relationship
    embedded_in :community
    
end

# as a version archiver
class UpdateLogger
    
end


class Community
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated
    include Mongoid::Geospatial
    
    field :name, type: String
    field :other_names, type: Array
    
    field :address, type: String   # TODO: to decide which is better, String or a document?
    field :location, type: Point
    field :area, type: Polygon
    
    
    field :populations, type: Array  # [number, source, memo/commentaries]
    
    # validation
    validates_uniqueness_of :name, { :scope => :address_component } # TODO: can scope apply to the embedded doc?
    
    # relationship
    embeds_one :address_component
    
    # scope
    scope :of_city, lambda { | city_name | where( "address_component.city" => city_name) }
    
    scope :of_city_and_district, lambda { | city_name, district_name | where("address_component.city" => city_name, "address_component.district" => district_name ) if city_name && district_name }
    
    # indexes
    spatial_index :location
    index({ name:1}, { name: "ct_ct_name"} )
    
    # indexes on embed doc
    index({"address_component.province" => 1})
    index({"address_component.city" => 1})
    index({"address_component.district" => 1})
    index({"address_component.street_name" => 1})
    
    index({ "address_component.city" => 1 , "address_component.district" => 1 } )# TODO: research what's diff with following
    index({ "address_component.province" => 1, "address_component.city" => 1 , "address_component.district" => 1 })
  
end # of class




if __FILE__ == $0
    
    
require File.join(File.dirname(__FILE__), 'conn_mongo.rb')
    
# -----

# # basic CRUD ops on community model

=begin
 # create one
 c1 = Community.new
 c1.name = "aaaaa"
 c1.other_names = ['aaab', 'aaac']
 c1.save
=end

=begin
 # retrieve one
 c2 = Community.where("name" => "aaaaa")
 puts "#{c2.first.name} has other names such as #{c2.first.other_names}"
=end

=begin
 # update
 c3 = Community.where("name" => "aaaaa")
 c3.first.update_attributes(:other_names => ['bbb','ccc'])
 puts "#{c3.first.name} has other names such as #{c3.first.other_names}"
=end

=begin
 # del
 c4 = Community.create!(:name => "toDel", :other_names => ['cc','dd'] )
 puts "#{c4.name} has other names such as #{c4.other_names}"
 c4.destroy
 c4 = Community.where(:name => "toDel")
 puts "#{c4.size <=0 ? 'target did Not found' : 'Wrong, supposed to be deleted!'}"  
=end
    
    
# -----
    
# # relationship CRUD test

=begin
  # create
 
  a1 = AddressComponent.new
  a1.city = "上海"
  a1.province = "上海市"
  a1.district = "黄浦" # "不存在"
  a1.street_name = "测试路名"
    
  c1 = Community.new
  c1.name = "aaaaa"
  c1.other_names = ['aaab', 'aaac']
    
  c1.address_component = a1
  c1.save!
=end
    
=begin

    # query on embedded doc
    all_sh = Community.where("address_component.city" => $SH_CITY)
    puts "total found: #{all_sh.count}"
    
    all_sh.each do | c |
       puts c.address_component.street_name
    end

    
    # scope test
    all_sh = Community.of_city($SH_CITY)
    puts "total found: #{all_sh.count}"
 
 
=end    
    
    #city_disct_grp = Community.
    
    
end
    
