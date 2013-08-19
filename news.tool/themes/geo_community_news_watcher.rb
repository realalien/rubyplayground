#encoding:UTF-8


# Purpose: dig the news from news source and do a book keeping



# ----- model -----

class GeoCommunity
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated

    include Mongoid::Geospatial

    
    field :full_name_cn, type: String
    field :other_names,  type: Array
    

    field :district_name_cn, type: String
    
    geo_field :location         # field :location, type: Point, spatial: true
    field :circumference, type: Array  # for later measurement
    
    
    # validation
    validates :full_name_cn,  :uniqueness => {:scope => :district_name_cn}

    
    # indexing
    spatial_index :location
end

# Mongoid::Indexing.create_indexes


# ----- process -----

class GeoCommunity_News_Keeper
    
    
  def self.watch_community(community_name)
    
  end

end



# ----- thinkings and decision makings -----

# Q: Embedding parsed data as embedded documents or external documents?
# A:
# THK: see if possible to ask each model for parsed data, external doc works as a linking for parsed data among different models! In that way, we can query easily for data on models(much difficult to query on multiple ext doc!)
#   When asking Model for parsed data, requesting program should offer versioned source code in order to give a basic idea of how the data was generated (instead of booking the program on our own!)

# 





if __FILE__  == $0
    
    
    GeoCommunity_News_Keeper.watch_community("")
    
    
end








