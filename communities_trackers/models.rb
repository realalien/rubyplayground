#encoding: UTF-8

require 'mongoid'
require 'mongoid_geospatial'

# Ref. http://mongoid.org/en/mongoid/docs/documents.html, Custom field serialization
class AddressComponent
    #field :province, type: String
    #field :city, type: String
    #field :district, type:String
    #field :streetName, type:String
    #field :streetNum, type:String
    
    # TODO: mongodi related stuff
    
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
    
    field :address, type: String
    field :location, type: Point
    field :area, type: Polygon
    
    
    field :populations, type: Array  # [number, source, memo/commentaries]
    
    # validation
    validates :name,  uniqueness: true # SUG: use scope, :uniqueness => {:scope => :address_components}
    
    
    # indexes
    spatial_index :location
    index({ name:1}, { name: "ct_ct_name"} )
    
    
end # of class




if __FILE__ == $0
    
    
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
    
