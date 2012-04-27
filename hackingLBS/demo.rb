#encoding: UTF-8

require 'rubygems'
require 'mechanize'
require 'uri'

require 'mongo'
require 'mongo_mapper'


require 'geokit'


require 'pp'
require File.join(File.dirname(__FILE__), "models.rb") 
#require File.join(File.dirname(__FILE__), "diggers.rb") 

$DATABASE_DEV = "lbs4community_dev"
$TOTAL_PAGE_REQUEST = 0

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
    query_link = "#{$DIANPING_SHOP_SEARCH_PATH}#{URI.escape(keywords)}"    
    return DianpingPageParser.shops_in_page query_link
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
    #note: programming by intention, this is the smallest goal I want to achieve

=begin     
    include Geokit::Geocoders
    res=MultiGeocoder.geocode('100 Spear st, San Francisco, CA')
    puts res.ll # ll=latitude,longitude
=end      
   
    # working on user's activities geo
    # user = Member.where(:dianping_id  => "4479248").first
    
    #user = Member.new
    #user.dianping_id = "2020768"
    #user.name = "Uknowily翅膀"
    #user.save
    
    #user = Member.where(:dianping_id  => "2020768").first
    
    #puts "The user is #{user}"
    
    #if user
        # 
        # puts user.reviewed_shops_pages
        # puts user.reviewed_shops.size
    #    puts user.most_reviewed_city_district
=begin        
        shops = user.reviewed_shops   # TODO: create a method that apply to all the elements of an array.
        puts "#{user.name}(ID:#{user.dianping_id}) reviewed following shops(#{shops.count})"
        pp shops[0].url 
        #pp shops[0].address_dianping
        
        shops.each do | shop |
            pp shop.address_dianping
        end
=end
        
    #end
  
=begin    
    shop = Shop.new
    shop.dianping_id = "4127819"
    shop.name = "马荣金地格林幼儿园"
    shop.save
    
    shop = Shop.where(:dianping_id  => "4127819").first
    if  shop
       people = shop.members_checked_in 
        people.each { |p| puts p.inspect}
    end
=end
    count = 0
    people_may_live_in_jiading = []
    kw = "嘉定区金地格林"
    shops_poi = dianping_search_shops(kw)
    puts "[INFO] Search shops by '#{kw}' ...... #{shops_poi.size} shop(s) found."
    
    shops_poi.each do |shop|
        people_once_checkedin = shop.members_checked_in
        puts "[INFO] #{shop.name} has #{people_once_checkedin.size} people checked in."
        count += people_once_checkedin.size
        people_once_checkedin.each do | person|
            city, area = person.most_reviewed_city_district
            if area == "嘉定区"
                people_may_live_in_jiading << person
            end
        end
        puts "[INFO] #{shop.name} all checked-in members processed----------------"
    end
    # chck
    people_may_live_in_jiading.each do | p|
       puts p.inspect 
    end
    
    puts "[INFO] #{people_may_live_in_jiading.size} out of #{count} may live in JiaDing"
=begin 
    #shops_poi = find_people_around_football_pitch_around_jindigeling
    kw = "嘉定区金地格林"
    shops_poi = dianping_search_shops(kw)  

    #Shop.collection.remove
    #Member.collection.remove
    #UpdateLog.collection.remove

    Explorable.ensure_index(:dianping_id)
    #Shop.ensure_index(:dianping_id)
    #Member.ensure_index(:dianping_id)
    
    
    #TODO:ESP: we should separate different model in different collection for sake of performance? 
    #          or distinguish objects using field like 'doc_type'?
    
    shops_poi.each do | shop|
        the_one = Shop.where(:dianping_id  => "#{shop.dianping_id}" ).first
        #p "the_one    #{the_one.inspect}"
        
        if the_one
            puts "Passed  #{shop.inspect}"
            puts shop.update_logs.all || "No logs for shop" #TODO: failed in retrieving asso.
            next
        else
            puts "Saving #{shop}"
            log = UpdateLog.create(:description => "webpage-parsing from shop search '#{kw}' , via: #{$DIANPING_SHOP_SEARCH_PATH}#{URI.escape(kw)}") 
            shop.update_logs << log
            shop.save
        end    
    end    
   
    #all_shops = Shop.all
    #puts all_shops.map { |object| object.name }.inspect
    
    p shops_poi
    users = []
    if  shops_poi.size > 0
        shop_eg = shops_poi[0]
        
        puts "----------------------------------"
        puts "#{shop_eg.name}  >> checkins are:"
        puts "----------------------------------"
        
        users = shop_eg.find_people_via_checkins
        
        
        p "==========="
        p "Total:  #{users.size}"
        users.each do | u |
            #puts "Search for member with id : #{u.dianping_id}"
            a = Explorable.where(:dianping_id => "#{u.dianping_id}").first
               
            #pp a 
            
            if a
                puts "Already exists #{a.name} ID:#{a.dianping_id}."
                puts a.update_logs.all || "No logs for member"   #TODO: failed in retrieving asso.
            else
                puts "Adding member[#{u.dianping_id}] to database..."
                log = UpdateLog.create(:description => "collected from #{shop_eg.url_checkins}") 
                u.update_logs << log 
                u.save
            end
        end
        
    end
  
=end

end




=begin


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
