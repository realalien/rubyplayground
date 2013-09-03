#encoding:UTF-8

require 'uri'
require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'yaml'

require 'geocoder'


DDMAP_CATEGORIES = { "美食" => "%C3%C0%CA%B3"  ,    # http://www.ddmap.com/map/21----%C3%C0%CA%B3----/
                     "住宅小区" => "D7%A1%D5%AC%D0%A1%C7%F8" ,
                     
}

$DDMAP_PAGINATION_RESULT_LIMIT = 25

SUB_CATEGORIES_DATA_FILE_NAME = "sub_categories.yaml"
SUB_LOCALITY_DATA_FILE_NAME   = "sub_locality.yaml"

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
def collect_all_city_code
    
end









# --- reading data
def read_sub_categories_by_city_code(city_code)
    # SUG: more detection logic on data freshing.
    unless File.exist?( sub_categories_filename_by_city_code(city_code) )
        cats = collect_sub_categories_by_city_code(city_code)
        if cats.size > 0
           dump_sub_categories_to_file(cats, city_code)
        else
            raise "[DEBUG] no sub categories found, please check the program!"
        end
    end

    File.open(  sub_categories_filename_by_city_code(city_code), 'r' ) do |yf|
        YAML.load( yf ) 
    end
end
    
# ----------

def read_sub_localities_by_city_code(city_code)
    
    unless File.exist?( sub_locality_filename_by_city_code(city_code) )
        sublocalities = collect_sub_locality_by_city_code(city_code)
        if sublocalities.size > 0
            # save to file
            dump_sub_locality_to_file(sublocalities, city_code)
        else
            raise "[DEBUG] no sub locatiry found, please check the program!"
        end
    end
    
    File.open(  sub_locality_filename_by_city_code(city_code), 'r' ) do |yf|
        YAML.load( yf )
    end
end



# ----- file based data file helper methods -----

# --- filename
def sub_categories_filename_by_city_code(city_code)
    File.join(File.basename(__FILE__,".rb") , "#{city_code}_#{SUB_CATEGORIES_DATA_FILE_NAME}" )
end


def sub_locality_filename_by_city_code(city_code)
    File.join(File.basename(__FILE__,".rb") , "#{city_code}_#{SUB_LOCALITY_DATA_FILE_NAME}" )
end

# --- dumping data
def dump_sub_categories_to_file(array_of_categories, city_code)
    File.open( sub_categories_filename_by_city_code(city_code), 'w' ) do |out|
        YAML.dump( array_of_categories, out )
    end
end

def dump_sub_locality_to_file(array_of_sublocality, city_code)
    File.open( sub_locality_filename_by_city_code(city_code), 'w' ) do |out|
        YAML.dump( array_of_sublocality, out )
    end
end


# --- retrieving data
def collect_sub_categories_by_city_code(city_code)
    categories = []
    
    # url
    city_code.gsub!(/^0+/, "") # remove leading zero
    url = "http://www.ddmap.com/sitemap/#{city_code}/1.htm"
    # xml process
    doc = Nokogiri::HTML(open(url))
    
    css_path = "html body div#body div.siteCon div.siteCon1 ul li.Con2 p a"
    
    doc.css(css_path).each do |link|
        categories << URI.unescape(link.content)
    end
    
    puts categories  if $VERBOSE
    return categories
end


def collect_sub_locality_by_city_code(city_code)
    localities = []
    
    # url
    city_code.gsub!(/^0+/, "") # remove leading zero
    url = "http://www.ddmap.com/sitemap/#{city_code}/1.htm"
    # xml process
    doc = Nokogiri::HTML(open(url))
    
    css_path = "html body div#body div.siteCon div.areaS ul li.areaS1 a"
    
    doc.css(css_path).each do |link|
        elem = URI.unescape(link.content)
        localities << elem unless localities.include?(elem)
    end
    
    puts localities  if $VERBOSE
    return localities
end


# ----------------------------------------------------------------------

# Q: Why I can't search node under one child node using xpath or css?
# A: 

# NOTE: the levels of data is collectable from sitemap, e.g. http://www.ddmap.com/sitemap/25/1.htm (http://www.ddmap.com/sitemap/<city_code>/1.htm)
# NOTE: the city_code may be not necessary in collecting categories since every city should has similar data. For now for the simplicity of data retriving and without proper phone prefix dataset, we just assign one city prefix, beginning from one city!
def collect_loc_categories(city_code)
    categories = {}
    
    # url
    city_code.gsub!(/^0+/, "") # remove leading zero
    url = "http://www.ddmap.com/sitemap/#{city_code}/1.htm"
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


# ---------------------------------------------------------------
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

# ---------------------------------------------------------------

def filename_for_places_by_city_category(city_code, category_name)
    File.join(File.basename(__FILE__,".rb") , "#{city_code}_#{category_name}" )
end


def dump_places_by_city_cateogry(places, city_code, category_name)
    File.open( filename_for_places_by_city_category(city_code, category_name), 'w' ) do |out|
        YAML.dump( places, out )
    end 
end


# keep updating with the wiki page, http://goo.gl/VLmmt8
def util_listing_avaiable_city_code
     
end

# ---------------------------------------------------------------



# --------------------
# data grabbing
# --------------------

# To query for a category of places(e.g. 住宅小区 is a sub category in ddmap.com), 
# the query link would be "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
# ( "http://www.ddmap.com/map/<city_code>/----<encoded_category_name>----/", 
#   in which the 'encoded_category_name' should be processed like, 
#      converter  = Iconv.new( "GB2312", "UTF-8" )
#      URI.encode_www_form_component( "#{converter.iconv( '黄浦区'.encode!('UTF-8') )}"  )
# ) 
# Q: why can't be one liner?
# A: 

# NOTE: probably this methods will get partial data as query results won't show up all,
# so this is just used for estimating total results number
# To find all the places belongs to a city, one should query using
def util_listing_categories_and_sublocality(city_code)
    allowed_cat = read_sub_categories_by_city_code(city_code)
    puts "Categories Allowed:\n #{allowed_cat.join(',')}"
    
    allowed_sub_localities  = read_sub_localities_by_city_code(city_code)
    puts "Sublocalities Allowed:\n #{allowed_sub_localities.join(',')}"
end

# ------------------------------------------------------------------------

#
def report_data_consistency
    # TODO: report data volumne expected(guessing by pages*pageSize) and data volumne collected (due to data filtering by websites).
    if all_places.size > 0
        dump_places_by_city_cateogry(all_places, city_code, category_name)
        puts "Total places: #{all_places.size}, given city:#{city_code}, category: #{category_name} "
        puts "Search/find your place in file dd_resources/#{city_code}_#{category_name}.yaml"
    else
        puts "No place found!"
    end
end


# either retrieve from local db/file or from internet
def read_places_by_city_locality_cateogry(city_code, sublocality_name, category_name)
    
    # --------  sanity check if input params are valid  ------
    allowed_cat = read_sub_categories_by_city_code(city_code)
    allowed_sub_localities  = read_sub_localities_by_city_code(city_code)
    
    
    unless ( allowed_cat.include?(category_name) and allowed_sub_localities.include?(sublocality_name) )
        puts "[WARNING] Either #{category_name} or #{sublocality_name} is not valid, please check with following values, "
        util_listing_categories_and_sublocality(city_code)
        puts "----------------------------------------------------------------"
        return  # no processing any more
    end
    
    # --------  afte all params are correct -------
    unless File.exist?( filename_for_places_by_city_sublocality_category(city_code, sublocality_name, category_name) )
        places = collect_places_by_city_sublocality_category(city_code, sublocality_name, category_name)
        
        if places.size > 0
            # save to file
            dump_places_by_city_locality_cateogry(places, city_code, sublocality_name, category_name)
        else
            raise "[DEBUG] no sub locatiry found, please check the program!"
        end
    end
    
    collected_places = []
    
    File.open( filename_for_places_by_city_sublocality_category(city_code, sublocality_name, category_name), 'r' ) do |yf|
        collected_places = YAML.load( yf )
    end
    
    puts collected_places if $VERBOSE
    
    collected_places
end

def dump_places_by_city_locality_cateogry(places, city_code, sublocality_name, category_name)
    File.open( filename_for_places_by_city_sublocality_category(city_code, sublocality_name, category_name), 'w' ) do |out|
        YAML.dump( places, out )
    end
end

def filename_for_places_by_city_sublocality_category(city_code, sublocality_name, category_name)
    File.join(File.basename(__FILE__,".rb") , "#{city_code}_#{sublocality_name}_#{category_name}" )
end

# ------------------------------------------------------------------------
                     
                     
class String
    def is_number?
        true if Float(self) rescue false
    end
end

# SUG: city_code
# sublocality: should be human-read text and listed in the city-specific page!
def collect_places_by_city_sublocality_category(city_code, sublocality, category_name)
    
    name_address_mapping = {}
    
    # get 'total pages' info, find the content with max 
    # TODO: this can be done when getting the first page of the list(query result).
    url = page_url_for_city_sublocality_category(1, city_code, sublocality, category_name )

    max_page = helper_find_total_page_num(url)
    
    if  max_page > $DDMAP_PAGINATION_RESULT_LIMIT
        puts "[INFO] #{max_page} pages of data found!"
        puts "---------------------------------------------------------------"
        puts "ddmap only allows 25 pages of query results. Following info may be partial."
        puts "link(starting page): #{url} "
        puts "---------------------------------------------------------------"
        
        
        # NOTE：because searching by locality has limited pages for grabing, we have to dig down to sub area for all the district
        subareas = helper_find_subarea_name_links(url)
        pp subareas
        
        # print out self made links
        subareas.each do | area|
            # TODO: see if memory is limited or not, we create many doc in each method call, otherwise, employ some kind of cassette mechanism for limiting web access.
            
            # first page
            first_page_link = page_url_for_city_subarea_category(1, city_code, area, category_name)
            puts "[Info] Processing #{first_page_link}" if $VERBOSE
            mappings_of_first_page = helper_process_name_address_mapping_for_url(first_page_link)
            name_address_mapping.merge!(mappings_of_first_page)
            # other pages
            paginations = helper_find_total_page_num(first_page_link)
            puts "[Info] Found pages #{paginations}   (#{first_page_link}, CITY_CODE: #{city_code}, sub area: #{area}, category: #{category_name})" if $VERBOSE
            
            (2..paginations).each do | page_num |
                other_page_link = page_url_for_city_subarea_category(page_num, city_code, area, category_name)
                puts "[Info] Processing #{other_page_link}  (of page #{page_num})" if $VERBOSE
                mappings_of_other_pages = helper_process_name_address_mapping_for_url(other_page_link)
                name_address_mapping.merge!(mappings_of_other_pages)
                
                
                pp name_address_mapping
                # raise "Intentional break!"
                
            end
        end
    else
        
        # NOTE: pagination under the limit, following search will not get sub area(one level deeper beyond the sublocality)
        puts "[INFO] #{max_page} pages of data found! Processing ..."
        
        # grabbing the first page which we already got when we try to find the total page
        mappings_of_first_page = helper_process_name_address_mapping_for_url(url)
        name_address_mapping.merge!(mappings_of_first_page)
        
        # grabbing the following page
        pages_to_grab = [max_page, $DDMAP_PAGINATION_RESULT_LIMIT].min
        (2..pages_to_grab).each do |page_num|
            puts "processing page ....  #{page_num}"  if $VERBOSE
            url = page_url_for_city_sublocality_category(page_num, city_code, sublocality, category_name )
            
            mappings = helper_process_name_address_mapping_for_url(url)
            name_address_mapping.merge!(mappings)
        end
    end
    
    name_address_mapping
end



# to find the pagination on one listing page
def helper_find_total_page_num(url)
    one_doc = Nokogiri::HTML(open(url))
    css_nav = "html body div.content div.listL div.PageNav ul li a"
    nodeset_nav = one_doc.css(css_nav)
    max_page = 1
    puts nodeset_nav || "no page nav"
    
    nodeset_nav.each do |node|
        #puts "-->  #{node.content}"
        max_page = node.content.to_i if node.content.is_number? and node.content.to_i > max_page
    end
    max_page
end

# to find all name:address infos in one listing page
def helper_process_name_address_mapping_for_url(url)
    one_doc = Nokogiri::HTML(open(url))
    mappings = {}
    css_path = "html body div.content div.listL div.listMode ul.infoList1 li.info_t"
    nodeset = one_doc.css(css_path)
    nodeset.each do | node |
        names_node = node.at_xpath(".//h3/a")   #puts URI.unescape(names_node.content)
        # there will be two, the first will be useful!
        addr_node = node.at_xpath(".//p/a")  # puts URI.unescape(addr_node.content)
        mappings[names_node.content] = addr_node.content
    end
    mappings
end

# to find the sub area under the sublocality(district) due to unreacheable data result from sublocality keyword search
def helper_find_subarea_name_links(url)
    one_doc = Nokogiri::HTML(open(url))
    subareas = []
    
    # css(*rule) ref. http://nokogiri.org/Nokogiri/XML/Node.html#method-i-css
    css_path = "html body div.content div.find div.area p.area_C a"
    nodeset = one_doc.css("#{css_path}:regex('w+')", Class.new {
      def regex node_set, regex
          node_set.find_all { |node| node['href'] =~ /---1/ }
      end
    }.new)
    nodeset.each do | node |
        #puts node['href']
        subareas << node.content
        #names_addr_node = node.at_xpath("./a")  # puts URI.unescape(addr_node.content)
        #mappings[names_addr_node.content] = names_addr_node
    end
    subareas
end


def page_url_for_city_sublocality_category(page_num, city_code, sublocality, category_name) # page_num starts from 1
    q = "http://www.ddmap.com/map/#{city_code}"
    converter  = Iconv.new( "GB2312", "UTF-8" )
    q += %Q{-#{URI.encode_www_form_component(converter.iconv(sublocality.encode!('UTF-8')))}}  # sublocality
    q += %Q{---#{URI.encode_www_form_component(converter.iconv(category_name.encode!('UTF-8')))}}  # category_name
    q += %Q{---#{page_num}-1/}  # pagination
end

#  sub area is one level deeper under sublocality, due to unreachable resultset from sublocality search. page_num starts from 1
def page_url_for_city_subarea_category(page_num, city_code, subarea, category_name)
    q = "http://www.ddmap.com/map/#{city_code}"
    converter  = Iconv.new( "GB2312", "UTF-8" )
    
    # TODO: why this is different from sublocaity scape/unscape?
    q += "--#{string_ddmap_encoding_chn_addr(subarea)}"  # subarea
    q += %Q{--#{URI.encode_www_form_component(converter.iconv(category_name.encode!('UTF-8')))}}  # category_name
    q += %Q{---#{page_num}-1/}
end
    

def util_listing_partial_addr_coord(name_address_mapping)
    # debug
    puts "Total places found: #{name_address_mapping.size}"
    name_address_mapping.each_pair do | k, v|
        puts "#{k}  => #{v}    #{Geocoder.coordinates(k)}"
        
        sleep 1
    end
end


def string_ddmap_encoding_chn_addr(chn_addr)
    addr_components = chn_addr.split(/\//)
    addr_converted = addr_components.map{|e| "#{Iconv.iconv('GB2312','UTF-8',URI.encode_www_form_component(e.encode!('GB2312')))[0]}" }.join("@L@")
end

# --------------------

# community extent data analysis

# e.g. news parsing for local highlight, it will be cool that the info links can be created, e.g. event->community->people on sns

# e.g. 区县代表选区

# e.g. foresee the near future of a specific area.

# e.g. find the most valueable reports and the authors who wrote them as credible sources!

# e.g. collect the best examples of community building activities and think tanks!

# e.g. research on community for capitals maneuvering, acurate attacks on speculators and maintaining the communities as a standing company.

# e.g. kml-based, multi-layers based researches on dev of the communities.


# I think of a game for collecting the buy-and-sell of houses
# > people who are going to buy and 
# > limit the daily usage in case of biz users
# > regular contribution of labour rewarded with more data in a larger range, or maybe targeted house area
# >  

# RESEARCH TOOL on http://www.alpha-cn.com/about.html?id=3#TC

# --------------------




if __FILE__ == $0
    
    # create project data filder
    #unless File.exist? File.basename(__FILE__, ".rb")
    #    Dir.mkdir(File.basename(__FILE__,".rb")) 
    #end
    
    
    #places = read_places_by_city_locality_cateogry("21", "虹口区", "住宅小区")
    #places = read_places_by_city_locality_cateogry("21", "徐汇区", "住宅小区")
    
    $VERBOSE = true
 
=begin
=end 

    require 'pp'
    
    city_code = "21"
    category_name = "住宅小区"
    # test of helper_find_subarea_name_links
    

    
    
=begin

   puts "%CB%C4%B4%A8%B1%B1%C2%B7\t(target:四川北路) "
   puts URI.unescape("%CB%C4%B4%A8%B1%B1%C2%B7")
   puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape("%CB%C4%B4%A8%B1%B1%C2%B7"))
   puts "-----"
   puts "#{URI.encode_www_form_component('四川北路')}\t(processed by:URI.encode_www_form_component)"
   converter  = Iconv.new( "GB2312", "UTF-8" )
   puts "#{converter.iconv('四川北路'.encode!('UTF-8') )}\t(processed by:Iconv.new.iconv)"
   puts Iconv.iconv( 'GB2312','UTF-8',URI.encode_www_form_component("四川北路".encode!('GB2312')) )
    puts URI.encode_www_form_component("四川北路".encode!('GB2312'))
=end
 
=begin
    # test of string_ddmap_encoding_chn_addr()
    a = "%BA%A3%C4%FE%C2%B7@L@%C6%DF%C6%D6%C2%B7"
    target = "海宁路/七浦路"
    a = "%C1%D9%C6%BD%C2%B7@L@%BA%CD%C6%BD%B9%AB%D4%B0"
    target = "临平路/和平公园"
    puts "#{a}\t(target:#{target}) "
    puts URI.unescape(a)
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape(a))
    puts "-----"
    puts URI.encode_www_form_component("临平路@L@和平公园".encode!('GB2312'))
    puts string_ddmap_encoding_chn_addr(target)
=end
    
    
=begin 
 
    #read_sub_categories_by_city_code("025")
    
    # collect_loc_categories("025")
    
    # collect_all_organizations "美食"
    # collect_places_by_city_sublocality_category("21", "黄浦区", "住宅小区")
 
 
    #util_listing_categories_and_sublocality("21")
    read_places_by_city_locality_cateogry("21", "虹口区", "住宅小区")
 
    # ------ encoding exp 
    
    Iconv.iconv( 'GB2312','UTF-8',URI.encode_www_form_component("四川北路".encode!('GB2312'))
 
    puts  URI.unescape("%BB%C6%C6%D6%C7%F8").encoding
    puts URI.encode_www_form_component("黄浦区")
    converter  = Iconv.new( "GB2312", "UTF-8" )
    puts URI.encode_www_form_component(  "#{converter.iconv( '黄浦区'.encode!('UTF-8') )}"  )
    puts URI.encode_www_form_component(  "#{Iconv.iconv('GB2312', 'UTF-8', '黄浦区'.encode!('UTF-8') )}"  )
    puts "---------"
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape("%BB%C6%C6%D6%C7%F8"))
    puts Iconv.iconv( 'GB2312','UTF-8',URI.unescape("黄浦区".encode!('GB2312')).encode!('UTF-8') )
    puts URI.encode_www_form_component("黄浦区")
    puts URI.encode_www_form_component("黄浦区").encode!('GB2312')
    puts URI.encode_www_form_component("黄浦区").encode!('UTF-8')

    puts Iconv.iconv('GB2312', 'UTF-8', "黄浦区")

    puts  URI.encode_www_form_component(   "黄浦区".encode!('GB2312', 'utf-8').encode!( 'utf-8','GB2312')  )
    
    ec = Encoding::Converter.new( "UTF-8","GB2312")

    puts "#{ec.convert('黄浦区')}"
    puts "#{converter.iconv(URI.encode_www_form_component('黄浦区'))}"
    #puts URI.encode_www_form_component(Iconv.iconv('GB2312', 'UTF-8', "黄浦区"))
    
    puts Iconv.iconv('GB2312', 'UTF-8', URI.encode_www_form_component("黄浦区"))
    puts "%BB%C6%C6%D6%C7%F8" == Iconv.iconv('GB2312', 'UTF-8', URI.encode_www_form_component("黄浦区"))
   
 
    # ------  link test
    link  = "http://www.ddmap.com/map/21----%D7%A1%D5%AC%D0%A1%C7%F8----/"
    text = "%D7%A1%D5%AC%D0%A1%C7%F8"
    puts Iconv.iconv('UTF-8', 'GB2312',URI.unescape(text))
 
 
=end    
end
