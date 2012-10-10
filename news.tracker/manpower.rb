#encoding:UTF-8


require 'mechanize' 
#require 'couch_potato'  # because we can write view(design doc) in ruby.
require 'mongoid'
#require 'mongoid_taggable'


Mongoid.configure do |config|
  name = "news_tracker_dev_manpower"
  host = "localhost"
  port = 27017
  config.database = Mongo::Connection.new.db(name)
  config.use_utc = true  # in case we retrieve data from international news source
end


# NOTE: 
# * this class serves as a helping entity for news tracking
# * to be simple to record basic information
# * to create machanism for modifying the extra info from various scripts rather that dangerous direct manipulation
class Individual
    
    include Mongoid::Document 
    include Mongoid::Timestamps # adds automagic fields created_at, updated_at
    

    field :name_cn, type: String  # 中文名
    field :name_en, type: String  # 英文名
    field :name_intl, type: String  # 所在地的本地文字表示的姓名
    field :name_conflict_resolver, type:String

    field :other_names, type: Array   # 别名 may be nicknames,  short names, 
    field :roles, type:Array # array of hash  {organization:xxx role:xxx duration:xxxx}


    field :location_first_met
    field :description_first_met  # 首次登记的描述，内容：最好有网络链接；point of interests；
   
    
    # VALIDATION
    validates_presence_of :description_first_met
    validates_presence_of :location_first_met
    
    validates_uniqueness_of :name_cn, :scope => [:name_cn, :name_en, :name_intl, :name_conflict_resolver]  # 不能完全相同，即使全部同名，必须有区分的信息
end



class Organization
	include Mongoid::Document 
    include Mongoid::Timestamps # adds automagic fields created_at, updated_at
    

    field :name_cn, type: String  # 中文名
    field :name_en, type: String  # 英文名
    field :name_intl, type: String  # 所在地的本地文字表示的姓名
    field :name_conflict_resolver, type:String

    field :other_names, type: Array   # 别名 may be nicknames,  short names, 


    field :description_first_met  # 首次登记的描述，内容：最好有网络链接；point of interests；
   
    
    # VALIDATION
    validates_presence_of :description_first_met
    
    validates_uniqueness_of :name_cn, :scope => [:name_cn, :name_en, :name_intl, :name_conflict_resolver]  # 不能完全相同，即使全部同名，必须有区分的信息
end




def missing_methods

end





module Sociality

def account_of_twitter
	
end

end


if __FILE__ == $0


=begin
	# -----------------  use case (self development) ------------------
	# ----- basic facilities
	kw_topic = "journalism"
	org = "Mercer University"

	people = __find_related_people__(kw_topic, org)  
	# suppose:
	# * use raw search engine to collect all articles including the organzations and people mentioned.
	# * add attributes for person
	# * record for later retrievals
	# * study of text mining

	people do | p |
	  p.role_at(org)  # deduced or human input!?
    end

    # ---- mining, probing
    # projects tracking, activities tracking for inspirations on community journalism
    # resources(money, human, VC, etc) comparing and mapping.
    # descision making based on pros and cons mapping



	#  -----------------  use case (auditing and monitoring) ------------------
=end







end