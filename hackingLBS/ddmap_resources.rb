#encoding:UTF-8

require 'uri'
require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'yaml'

DDMAP_CATEGORIES = { "美食" => "%C3%C0%CA%B3"  ,    # http://www.ddmap.com/map/21----%C3%C0%CA%B3----/
                     "住宅小区" => "D7%A1%D5%AC%D0%A1%C7%F8" ,
                     
}


SUB_CATEGORIES_DATA_FILE = "sub_categories.yaml"


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

# 
def collect_place_all_sub_categories(city_phone_prefix)
    categories = []
    
    # url
    city_phone_prefix.gsub!(/^0+/, "") # remove leading zero
    url = "http://www.ddmap.com/sitemap/#{city_phone_prefix}/1.htm"
    # xml process
    doc = Nokogiri::HTML(open(url))
    
    css_path = "html body div#body div.siteCon div.siteCon1 ul li.Con2 p a"
    
    doc.css(css_path).each do |link|
        categories << URI.unescape(link.content)
    end
        
    puts categories
    return categories    
end


def project_sub_categories_location(area_code)
    File.join(File.basename(__FILE__,".rb") , "#{area_code}_#{SUB_CATEGORIES_DATA_FILE}" ) 
end




def dump_sub_categories_to_file(array_of_categories, area_code)
    File.open( project_sub_categories_location(area_code), 'w' ) do |out|
        YAML.dump( array_of_categories, out )
    end 
end


def read_sub_categories_by_area_code(area_code)
    # TODO: more detection logic on data freshing.
    unless File.exist?( project_sub_categories_location(area_code) )
        cats = collect_place_all_sub_categories(area_code)
        if cats.size > 0
           dump_sub_categories_to_file(cats, area_code)
        else
            raise "[DEBUG] no sub categories found, please check the program!"
        end
    end

    File.open(  project_sub_categories_location(area_code), 'r' ) do |yf|
        YAML.load_documents( yf ) 
    end
end
    
# ----------

def read_sub_localities_by_city_code(city_phone_prefix)
    
end


# ----------

# Q: Why I can't search node under one child node using xpath or css?
# A: 

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


def filename_for_places_by_city_category(city_phone_prefix, category_name)
    File.join(File.basename(__FILE__,".rb") , "#{city_phone_prefix}_#{category_name}" )
end 

def dump_places_by_city_cateogry(places, city_phone_prefix, category_name)
    File.open( filename_for_places_by_city_category(city_phone_prefix, category_name), 'w' ) do |out|
        YAML.dump( places, out )
    end 
end


# --------------------
# data grabbing
# --------------------

# To query for a category of places(e.g. 住宅小区 is a sub category in ddmap.com), 
# the query link would be "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
# ( "http://www.ddmap.com/map/<city_phone_prefix>/----<encoded_category_name>----/", 
#   in which the 'encoded_category_name' should be processed like, 
#      converter  = Iconv.new( "GB2312", "UTF-8" )
#      URI.escape( "#{converter.iconv( '黄浦区'.encode!('UTF-8') )}"  )
# ) 
# Q: why can't be one liner?
# A: 

# NOTE: probably this methods will get partial data as query results won't show up all,
# so this is just used for estimating total results number
# To find all the places belongs to a city, one should query using
def get_places_by_city_phone_prefix_category_name(city_phone_prefix, category_name)
    
    allowed_cat = read_sub_categories_by_area_code(city_phone_prefix)
    puts "Categories loaded! "
    puts "#{allowed_cat.join(',')}"
    
    allowed_sub_localities  = read_sub_localities_by_city_code(city_phone_prefix)
    puts "Sublocalities loaded! "
    puts "#{allowed_sub_localities.join(',')}"
    
    
    if allowed_cat.include? category_name and allowed_sub_localities.size > 0
        
        all_places = []
        allowed_sub_localities.each do | loc |
           places = get_places_by_city_sublocality_category(city_phone_prefix, loc, category_name)
           all_places + places
        end
        
        if all_places.size > 0
            dump_places_by_city_cateogry(all_places, city_phone_prefix, category_name)
            puts "Total places: #{all_places.size}, given city:#{city_phone_prefix}, category: #{category_name} "
            puts "Search/find your place in file dd_resources/#{city_phone_prefix}_#{category_name}.yaml" 
        else
            puts "No place found!"
        end
    else 
        puts "Either #{category_name} or #{category_name} is not permitted!"
    end
    
    
end

# SUG: city_phone_prefix
# sublocality: should be human-read text and listed in the city-specific page!
def get_places_by_city_sublocality_category(city_phone_prefix, sublocality, category_name)
    
    doc = Nokogiri::HTML(open(url))

end

def page_url_for_city_sublocality_category(page_num) # page_num starts from 1
    q = "http://www.ddmap.com/map/#{city_phone_prefix}"
    converter  = Iconv.new( "GB2312", "UTF-8" )
    q += %Q{-URI.escape( "#{converter.iconv( sublocality.encode!('UTF-8') )}"  )}  # sublocality
    q += %Q{---URI.escape( "#{converter.iconv( sublocality.encode!('UTF-8') )}"  )}  # category_name
    q += %Q{---#{page_num}-1}  # pagination
end


# --------------------


if __FILE__ == $0
    
    # create project data filder
    unless File.exist? File.basename(__FILE__, ".rb")
        Dir.mkdir(File.basename(__FILE__,".rb")) 
    end
    
    
    
    get_places_by_city_sublocality_category("21", "黄浦区", "住宅小区")
    
    
=begin 
 
    #read_sub_categories_by_area_code("025")
    
    # collect_place_categories("025")
    
    #collect_all_organizations "美食"
 
 
    # ------ encoding exp 
    puts  URI.unescape("%BB%C6%C6%D6%C7%F8").encoding
    puts URI.escape("黄浦区")
    converter  = Iconv.new( "GB2312", "UTF-8" )
    puts URI.escape(  "#{converter.iconv( '黄浦区'.encode!('UTF-8') )}"  )
    puts URI.escape(  "#{Iconv.iconv('GB2312', 'UTF-8', '黄浦区'.encode!('UTF-8') )}"  )
    puts "---------"
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape("%BB%C6%C6%D6%C7%F8"))
    puts Iconv.iconv( 'GB2312','UTF-8',URI.unescape("黄浦区".encode!('GB2312')).encode!('UTF-8') )
    puts URI.escape("黄浦区")
    puts URI.escape("黄浦区").encode!('GB2312')
    puts URI.escape("黄浦区").encode!('UTF-8')

    puts Iconv.iconv('GB2312', 'UTF-8', "黄浦区")

    puts  URI.escape(   "黄浦区".encode!('GB2312', 'utf-8').encode!( 'utf-8','GB2312')  )
    
    ec = Encoding::Converter.new( "UTF-8","GB2312")

    puts "#{ec.convert('黄浦区')}"
    puts "#{converter.iconv(URI.escape('黄浦区'))}"
    #puts URI.escape(Iconv.iconv('GB2312', 'UTF-8', "黄浦区"))
    
    puts Iconv.iconv('GB2312', 'UTF-8', URI.escape("黄浦区"))
    puts "%BB%C6%C6%D6%C7%F8" == Iconv.iconv('GB2312', 'UTF-8', URI.escape("黄浦区"))
   
 
    # ------  link test
    link  = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    text = "%D7%A1%D5%AC%D0%A1%C7%F8"
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape(text))
 
 
=end    
end
