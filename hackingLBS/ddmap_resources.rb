#encoding:UTF-8

require 'uri'
require 'nokogiri'
require 'open-uri'
require 'iconv'


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


# ------------------------------
# General Categoring Data
# ------------------------------
def collect_all_city_phone_prefix
    
end



# NOTE: the levels of data is collectable from sitemap, e.g. http://www.ddmap.com/sitemap/25/1.htm (http://www.ddmap.com/sitemap/<city_phone_prefix>/1.htm)
# NOTE: the city_phone_prefix may be not necessary in collecting categories since every city should has similar data. For now for the simplicity of data retriving and without proper phone prefix dataset, we just assign one city prefix, beginning from one city!
def collect_place_categories(city_phone_prefix)
    categories = {}
    
    # url
    city_phone_prefix.gsub!(/^0+/, "") # remove leading zero
    url = "http://www.ddmap.com/sitemap/#{city_phone_prefix}/1.htm"
    # xml process
    doc = Nokogiri::HTML(open(url))
    css_path = "html body div#body div.siteCon div.siteCon1"
    
    # search for list of 'ul' under above css_path
    doc.at_css(css_path).children.each do | ul |
        # first 'li' is 1st level category
        first_cat = ul.at_xpath("li[@class='Con1']/a")
        first_cat.children.each do  |link |
            puts URI.unescape(link.content)
        end
        # second 'li' are list of 2nd level category, contained in all the links wrapped in <p>
        #        second_cat = ul.at_xpath("//li[@class='Con2']")
        #second_cat.children.each do | p |
        #    link = p.at_xpath("//a")
        #    puts URI.unescape(link.content) if link
        #end
        # third 'li' are the 'more' link, not very useful now!
        
        puts "--------------"
    end
    
    
    # dump the data
    
end




# ------------------------------

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
    housing_unlimit_areas = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    doc = Nokogiri::HTML(open(housing_unlimit_areas))
    
    
    css_path = "html body div.content div.find div.area ul"
    doc.css(css_path).each do | link|
        # filter out the 
        
    end
        
end    



def find_areas_for_category_experimental(category)
    areas = {}
    # TODO: temp hard coded data
    housing_unlimit_areas = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    doc = Nokogiri::HTML(open(housing_unlimit_areas))
    #xpath = "/html/body/div[@class='content']/div[@class='find']/div[@class='area']/ul/li[@class='area_R']"  # TODO: not strict, volative, watch out assertion cases! NOTE: should behave nice whether called one time or multiple times in some kind of looping. Q:what the hell I also got the service categories? A:
    
#    doc.xpath(xpath).each do | link |
#      puts "#{link['href']}    #{link.content}"
#       areas["#{link.content}"] =  "#{link['href']}"
#    end
 
  #ec = Encoding::Converter.new("GB2312", "UTF-8")
  #converter  = Iconv.new("gb2312", "UTF-8")   

  css_path = "html body div.content div.find div.area ul li.area_R"
  doc.css(css_path).children.each do | link|

    #puts doc.at_css(css_path).parent.children[0].content

    #if doc.at_css(css_path_guard)
      #puts "#{link['href']}    #{ec.convert(link.content)}"
      #puts "#{link['href']}    #{converter.iconv(link.content)}"
      #puts "#{link['href']}    #{Iconv.iconv('UTF-8', 'GB2312',link.content)}"
    #puts link.parent.parent['id'] 
	puts "-----------------"
    if link.parent.parent['id'].nil?  
      puts "#{link['href']}    #{link.content}"
      #puts "#{link['href']}    #{link.content.encode('UTF-8','GB2312')}"
      areas["#{link.content.gsub!(/\n\t\r/,'')}"] =  "#{link['href']}"
	end
  end

  #puts areas
  return areas
end



# --------------------


if __FILE__ == $0

    
    
    collect_place_categories("025")
    
    #collect_all_organizations "美食"
    
=begin    
    #
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape("%BB%C6%C6%D6%C7%F8"))
 
    # link test
    link  = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    text = "%D7%A1%D5%AC%D0%A1%C7%F8"
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape(text))
 
 
=end    
end
