#encoding:UTF-8

require 'yaml'
require 'pp'

require "../../hackingLBS/demo.rb"

#TASK: find the blogs written by a group of people in a specific neighbourhood (seeking potential contributors for local news, if no )

# NOTE: because people who wrote blogs don't tend to disclose their real locations(e.g.gps service not enabled, or for the sake of privacy, etc), to locate the users location, it is planned to use users's other sns accouts for check-ins(activity) data or text-mining the blog content. Also by mean of that process, we can first pinpoint the user's neighbourhood.
# NOTE: Remember we shouldn't have too many assumptions about how the data will be, so choose by highest probablities and don't lose the ways/targets in data!

# scenario, given an douban/twitter/sns account, find user's living neighbourhood, then dig for his/her blogs

# 

# ------------------------------------

# TODO: unfin
# for the sake of easy manipulation and dynamic attributes, use hash to process data(e.g. taking advantage of nosql db)
def get_shops_by_keywords_from_dianping(kw)
    
    # read local data file for data already crawled. (similar code from hackingLBS/ddmap_resources.rb
    Dir.mkdir("data") unless File.exists?("data")
    
    saved = Dir.glob("./data/search_#{kw}.yml")
    shops = []
    if saved.size <=0
        shops = temp_crawling("#{kw}") 
    else
        saved.each do |filename|
            shops  |= YAML::load( File.open(filename) )
        end
    end
    p shops 
end


def people_once_checkins_from_dianping(kw)
    people_in_hashes = []
    saved_people = Dir.glob("./data/people_checkins_by_shop_search_#{kw}.yml")
    
    
    if saved_people.size <=0
        # collect shops first
        shops = get_shops_by_keywords_from_dianping(kw) 
        
        # find checkins shop by shop
        shops.each do | shop_in_hash |
            shop_obj = Shop.new  # to use Shop methods, I have to create after model
            shop_in_hash.each { |k, v| shop_obj.instance_variable_set("@#{k}", v)
 }
            
            shop_obj.members_checked_in.each do | person |
                people_in_hashes << person.to_hash
            end
            
        end
        
        people_in_hashes.flatten!
        
        File.open("data/people_checkins_by_shop_search_#{kw}.yml", "w") {|f| f.write(people_in_hashes.to_yaml) }
        
    else
        saved_people.each do |filename|
            people_in_hashes  |= YAML::load( File.open(filename) )
        end
    end
    p people_in_hashes 
    
    people.flatten!
end


module  ActiveRecordExtension
    def to_hash
        hash = {}; self.attributes.each { |k,v| hash[k] = v }
        return hash
    end
end

class Explorable
    include ActiveRecordExtension
end

# TODO: refactor to tool util class
# TODO: memory mgmt
def temp_crawling(keyword)
    
    shops_modelled_selfmade = dianping_search_shops(keyword, 3)
    
    shops_modelled_selfmade.flatten! # TODO: should be somewhere else
    
    # convert to hashes
    shops_in_hashes = []
    shops_modelled_selfmade.each do |shop|        
        shops_in_hashes << shop.to_hash
    end
    # save to local files
    File.open("data/search_#{keyword}.yml", "w") {|f| f.write(shops_in_hashes.to_yaml) }
    
    return shops_in_hashes
end


# ------------------------------------

#module WebSocialMedia; end
module CheckAndEmpower
  
  def is_sns_account?

  end

  def dig_for 

  end


end


if __FILE__ == $0
    # 01.  
    # weibo_user_1 = "unknown"
    # 02. just find his/her blogs
    
    
    # 1. given a geo location, find some candidate people for analysing
    geo_name_rough = "嘉定城区"   # 'rough' means the place name is not accurate, just from my(human) natural recall or web search ( e.g. "嘉定城区" is from anjuke.com classification)
    
    # 1.1.1 given a geo name, find local biz (from dianping).  
    #rough_shops = get_shops_by_keywords_from_dianping(geo_name_rough) # rough because I don't use dianping's classifications
    
    # 1.1.x given a geo name, find neighborhood (some real estate website?)
    
    # 1.2 use dianping.com find people once check-ins(Q: any else way in finding users? A: )
    
    people_once_checkins  = people_once_checkins_from_dianping(geo_name_rough)
    

    
    
    # 1.3 analyse concentration of users's checkin', if find potential candidates, record!
    

end


