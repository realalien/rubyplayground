#encoding:UTF-8

require 'uri'
require 'nokogiri'
require 'open-uri'

DDMAP_CATEGORIES = { "美食" => "%C3%C0%CA%B3"  ,    # http://www.ddmap.com/map/21----%C3%C0%CA%B3----/
                     "住宅小区" => "D7%A1%D5%AC%D0%A1%C7%F8" ,
                     
}




# it looks like the escaped text in the link is not easily decoded, we need to get the mapping info instead of text encoding for tasks like querying
=begin
# NOTE: link comparison
#        "大楼住宅" (大类) http://www.ddmap.com/map/21-%BB%C6%C6%D6%C7%F8---%B4%F3%C2%A5%D7%A1%D5%AC----/
#        "住宅小区" (小类) http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/   (区域不限)
#         <a href='/map/21-%BB%C6%C6%D6%C7%F8---%D7%A1%D5%AC%D0%A1%C7%F8----1/' class='area_B'>黄浦区</a>
#         <a href='/map/21-%BE%B2%B0%B2%C7%F8---%D7%A1%D5%AC%D0%A1%C7%F8----1/' class=''>静安区</a>
#         <a href='/map/21-%D0%EC%BB%E3%C7%F8---%D7%A1%D5%AC%D0%A1%C7%F8----1/' class=''>徐汇区</a>
#         ....
=end

def find_categories_link_mapping

end


def query_for_organization(category, area)
    
end



# NOTE: ddmap at the moment only shows first 25 pages of query data, so we need to query with area included to get all data! But we can use this page to gather all the 'areas data'("区域")
def collect_all_organizations(category, area=nil)
    organizations = {}
    areas = {}
    
    if DDMAP_CATEGORIES.keys.include? category
        areas = find_areas_for_category(category)
    else
        puts "Got:#{category}, but expect one of the following:\n[#{DDMAP_CATEGORIES.keys.join(',')}]"
    end
    
end


def find_areas_for_category(category)
    areas = {}
    # TODO: temp hard coded data
    housing_unlimit_areas = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    doc = Nokogiri::HTML(open(housing_unlimit_areas))
    xpath = "//div[@class='find']/div[@class='area']/ul/li[@class='area_R']"  # TODO: not strict, volative, watch out assertion cases! NOTE: should behave nice whether called one time or multiple times in some kind of looping.
    
    doc.xpath(xpath).each do | link |
       puts "#{link['href']}    #{link.content}"
       areas["#{link.content}"] =  "#{link['href']}"
    end
    

    return areas
end



# --------------------


if __FILE__ == $0

    
    
    collect_all_organizations "美食"
    
    
=begin
    # link test
    link  = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    text = "%D7%A1%D5%AC%D0%A1%C7%F8"
    puts URI.unescape(text)
    
    
=end    
end