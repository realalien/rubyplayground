#encoding: UTF-8

require 'rubygems'
require 'mechanize'
require 'uri'

require 'mongo'
require 'mongo_mapper'

require 'pp'
require File.join(File.dirname(__FILE__), "models.rb") 


$DATABASE_DEV = "lbs4community_dev"

#TODO: exception handling when dealing with url.
$a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

$connection = Mongo::Connection.new("localhost")
$db = $connection.db($DATABASE_DEV)


# MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = $DATABASE_DEV
shops =  MongoMapper.database.collection("shops")


#MongoMapper.database.collections.each do |c|
#    puts c
#    #c.drop
#end

#MongoMapper.database $DATABASE_DEV

#note: programming by intention, this is the smallest goal I want to achieve
def find_people_around_football_pitch_around_jindigeling
  find_shops
end

def find_shops
  kw = "嘉定区金地格林"
  dianping_search_shops(kw)  
end

$DIANPING_SHOP_SEARCH_PATH = "http://www.dianping.com/search/keyword/1/0_" #TODO: watch-out mechanism ffor future change.

# Returns an array of shops via a Dianping.com's search
#TODO: handling no record scenario, 
#TODO: make sure the geo context is correct.
#play: more search via geo location
#play: watch out for updated information, redo the search or history book-keeping.

def dianping_search_shops(keywords)
    shops = []
    query_link = "#{$DIANPING_SHOP_SEARCH_PATH}#{URI.escape(keywords)}"
    p query_link
    $a.get(query_link) do |page|
        page.links. each do | link |
            # p link.href
            if link.href =~ /\/shop\/[0-9]+$/ 
                # p "----->  #{link.href}"
                s = Shop.created_from_link(link)  
                p s
                shops << s  # Shop.created_from_link(link)  
            end
        end 
    end
    return shops
end

# Returns an array of users whose check-ins were recorded in a specific shop.
#

def dianping_shop_checkins(shop)
    if shop is_a? Shop
        users = Shop.find_people_via_checkins
    end
    return users || []

end



if __FILE__ == $0

    
    shops_poi = find_people_around_football_pitch_around_jindigeling
    Shop.ensure_index(:dianping_id)
    #Shop.collection.remove
    
=begin     
    shops_poi.each do | shop|
        the_one = Shop.find_by_dianping_id shop.dianping_id
        if the_one
            puts "Passed  #{shop.dianping_id}"
            next
        else
            puts "Saving #{shop.dianping_id}"
            shop.save
        end    
    end    
   
    all_shops = Shop.all
    puts all_shops.map { |object| object.name }.inspect
    
=end    
    p shops_poi
    users = []
    if  shops_poi.size > 0
        shop_eg = shops_poi[0]
        
        puts "--------------------------------"
        puts "#{shop_eg.name}  >> checkins are:"
        puts "--------------------------------"
        
        users = shop_eg.find_people_via_checkins
        p users
    end

end





=begin

=end
#u1 = Member.new nil

#u1
=begin

def try_out_mechanize
  a.get('http://q.dianping.com/member/17234570') do |page|
    p page.links
  end
end

=end

# life-utlities  sample code, not working!!!

=begin
require 'rubygems'
require 'date'
require 'pp'
require 'open-uri'

require 'rexml/document'
require 'htree'
require 'fileutils'
require 'optparse' 

require 'ostruct'
Encoding.default_external = 'utf-8'
 
src_url = "http://q.dianping.com/member/17234570" 

    pdf_urls = []

    begin
      open(src_url) {
        |page| page_content = page.read().force_encoding("ISO-8859-1").encode("UTF-8")
        doc = HTree(page_content).to_rexml
        doc.root.each_element('//a')  do |elem |
          #puts elem
          a = elem.attribute("href").value
          if a =~ /shop\/[0-9]+$/
            pdf_urls << File.join(src_url.slice(0,src_url.rindex('/')),a)
            pdf_urls.uniq!
          end
        end
      }
      p(pdf_urls)
    rescue => e
    p e.message
      p e.backtrace
      puts "#{src_url} failed to open!" 
      raise "please check URL #{src_url}"       
    end
=end
