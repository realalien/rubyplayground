require 'rubygems'
require 'mechanize'  # this should be wrapped in one place, e.g. util class. Q: do we need to do the require?
require 'pp'

$DIANPING_BASE_URL = "http://www.dianping.com/"

$b = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
}


class UpdateLog
    include MongoMapper::Document
    
    key :description, String, :required => true
    timestamps!
    
    belongs_to :shop
    belongs_to :member
end

# TODO: see if we can make it a module!
class Explorable
    # MongoMapper's 
    include MongoMapper::Document
    

    key :dianping_id, String, :required => true
    key :name, String
    key :_type, String
    
    many :update_logs
    
    attr_accessor :dianping_id, :name, :link
    
=begin    
    def initialize(dianping_id)
		@dianping_id = dianping_id
    end
=end
    
    def ==(another)
        @dianping_id == another.dianping_id
    end

    def add_attributes(attrs, log)
        attrs.each_pair do | key, value |
           self[key] = value 
        end
        
        self.update_logs << log
        
        self.save
    end

end

class DianpingPageParser
    
    # TODO: handle the pagination
    def self.shops_in_page(url)
        shops = []
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        puts "[INFO] DianpingPageParser#shops_in_page...begin (#{url})"
        page = m.get(url) 
    
        # First page of personal review, also find the pagination.
        #puts page
        page.links.each do | link |
            if link.href =~ /\/shop\/[0-9]+$/ 
                s = Shop.new 
                s.dianping_id = File.basename(link.href)
                s.name = link.text  || ""
                s.link = link
                
                #p s
                shops << s  # Shop.created_from_link(link)  
            end
        end

        # shops in other pages
        

        puts "[INFO] DianpingPageParser#shops_in_page...end"
        return shops
    end
	
	# TODO: handle the pagination
    def self.members_in_page(url)
        members  = []
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        puts "[INFO] DianpingPageParser#members_in_page...begin (#{url})"
        m.get(url) do |page|
            #puts page
            page.links.each do | link |
                if link.href =~ /\/member\/[0-9]+$/ 
                    s = Member.new 
                    s.dianping_id = File.basename(link.href)
                    s.name = link.text  || ""
                    s.link = link
                
                    if members.include?(s)
                        #TODO:DIG: sniff for more refined data.
                        #if one.is_refined?
                        # TODO: replace or update the old data.
                        #end
                        
                        #experimental, refine the name of the member
                        old_index = members.find_index s
                        #puts old_index
                        if old_index != nil
                            # puts members[old_index].name
                            if members[old_index].name.empty? && !s.name.empty?
                                members[old_index].name = s.name #TODO: not replace, keep logging.
                                puts "Updating member's name...from: [#{members[old_index].name}] to #{s.name}"
                            end
                        end
                    else
                        #puts "[INFO] found new member: %d", 
                        members << s
                    end                 
                end
            end 
        end
        puts "[INFO] DianpingPageParser#members_in_page...end"
        return members
    end
	
    
    def self.number_of_pages(url_has_pagination) # use page to avoid multiple times of retrieving and parsing
        
        # NOTE: hint: reviews pagination is in <div class="Pages"/>,  
        # actually find all the  <a class='PageLink'>,  find the max one in innerText.

        #  * if there is a "<span class="PageMore">...</span>", then we can get the max page number by the next one in the all page links array
        #  * if there isn't a 'pagemore', the max page number is in the page link one ahead of 'next Page' 
        xpath = "//a[@class='PageLink']"
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        puts "[INFO] DianpingPageParser#number_of_pages...begin (#{url_has_pagination})"
        page = m.get(url_has_pagination)
        
        node_set = page.search(xpath)

        if node_set and node_set.length > 0 
            # collect all the inner text an 
            page_numbers = []
            node_set.each do | node|
                page_numbers << node.inner_text.to_i
            end
            
            return page_numbers.sort.last
        else
            return 1  # only one page, no pagination
        end
        
    end

    def self.get_one_item_from_xpath(xpath, page) # use page to avoid multiple times of retrieving and parsing
        node_set = page.search(xpath)   #puts "node_set length : #{node_set.length} "
        
        if node_set and node_set.length == 1
            value = node_set[0].inner_text
            return value
        else
            # TODO: halt and report!!!
            puts "[Error] Only one node is expected for xpath #{xpath}."
            return nil
        end
    end
    
    def self.structrued_address(shop_url)        
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        puts "[INFO] DianpingPageParser#structrued_address...begin (#{shop_url})"

        page = m.get(shop_url)
        
# TODO: exception handling when parsing!!!!!

        # -- city
        # NOTE: find node like 
        # <a href="http://www.dianping.com/citylist" id="G_loc" class="loc-btn"><span class="txt">上海站</span></a>
        xpath = "//div[@class='location' and @id='G_loc-wrap']/a[@href='http://www.dianping.com/citylist' and @id='G_loc']/span[@class='txt']"
        city = DianpingPageParser.get_one_item_from_xpath(xpath, page)
        
        # -- district  
        xpath = "//span[@class='region' and @itemprop='locality region']"
        district = DianpingPageParser.get_one_item_from_xpath(xpath, page)

        # -- address  
        xpath = "//span[@itemprop='street-address']"
        address = DianpingPageParser.get_one_item_from_xpath(xpath, page)
     
        return [city, district, address]
    end
    

end  # of class DianpingPageParser

# TODO: some comparison methods 

class Member  < Explorable
  
    #include Explorable
    #many :update_logs
    
    # Create member instance from member id observed, for the cases that the user is not created from other Dianping data.

    def self.created_from_link(link)
        id_in_link = File.basename(link.href)
        one = Member.new id_in_link
        one.link = link;
        # IDEA: update record logging for history tracking here!
        return one
    end


    def url
        return File.join($DIANPING_BASE_URL, "member/#{self.dianping_id}")
    end

    def reviews_url
        return File.join(self.url, "reviews") 
    end

    # NOTE: no need to store the relationships, just crawling the pages and s
    # IDEA:  API calls can be chained, aShop.checkins[<index_or_member name>].active_areas
    # NOTE: the reviews may have multiple pages, this should be handled in DianpingPageParser, rather than in Member class!
    def reviewed_shops
        shops = []
        # first page
        shops += DianpingPageParser.shops_in_page(reviews_url)
        # other pages
        if reviewed_shops_pages >=2
            (2..reviewed_shops_pages).each do | page_number |
                shops += DianpingPageParser.shops_in_page(File.join(reviews_url, "?pg=#{page_number}"))
            end
        end
        
        return shops
    end

    def reviewed_shops_pages
        return  DianpingPageParser.number_of_pages reviews_url
    end

    def most_reviewed_city_district
        # NOTE: I think of two coding method, one is to use map-reduce of NoSQL products or use Ruby language  suger of grouping data.
        
        
        # EXPERIMENTAL
        # find the city most visited,
        most_active_city = nil;
        most_active_district = nil;
        
        shops = reviewed_shops
        # reused by city_visits and area_visits
        group_by_city_addrs = shops.collect{|shop| shop.address_dianping}  # array
                                   .group_by {|element| element[0]}  # hashmap
        
        city_visits = group_by_city_addrs.map {|k,v| [k, v.length]} # hashmap
                                   .sort_by {|k,v| v}  # hashmap
                                   .reverse   # array
        city_visits ||= []
        if city_visits.size > 0
            puts "[DEBUG] Most visited city is #{city_visits[0][0]} #{city_visits[0][1]}/#{shops.size} ratio:(#{city_visits[0][1] * 1.0/shops.size })"
            most_active_city = city_visits[0][0]
            
            # find most visited areas
            addrs_in_most_visited_city = group_by_city_addrs[most_active_city] # array of [city,district, address]
            # TODO: how to handle address without district?!
            # TODO: is it necessary to be objected-oriented?
            group_by_district_addrs = addrs_in_most_visited_city.group_by {|element| element[1]} 
            district_visits = group_by_district_addrs.map {|k,v| [k, v.length]} # hashmap
                                            .sort_by {|k,v| v}  # hashmap
                                            .reverse   # array
            district_visits ||=[]
            if district_visits.size > 0
                puts "[DEBUG] Most visited district is #{district_visits[0][0]} #{district_visits[0][1]}/#{shops.size} ratio:(#{district_visits[0][1] * 1.0/shops.size })"
                most_active_district = district_visits[0][0]
            end
        else
            puts "[DEBUG] No shops visited."
        end
        
        
        
    end
end



# ======================================================================================


# NOTE: For now, it's only model after shops of 'dianping.com', mainly according to the observable information.

#

# TODO: experiment      


class Shop   < Explorable
    #many :update_logs
    
    
    #include Explorable
    
    # Create member instance from member id observed, for the cases that the user is not created from other Dianping data.
    def self.created_from_link(link)
        id_in_link = File.basename(link.href)
        one = Shop.new id_in_link
        one.link = link;
        # IDEA: update record logging for history tracking here!
        return one
    end


    def url
        return File.join($DIANPING_BASE_URL, "shop/#{self.dianping_id}")
    end

    def url_checkins
        return File.join(self.url, "gone")
    end

    # Find a list of people via checkin pages.
    def find_people_via_checkins
        return DianpingPageParser.members_in_page url_checkins
    end

    # IDEA: we can check for difference in data of different 
    def address_dianping
        return DianpingPageParser.structrued_address url  #[cityname, district_name, No.&road]
    end
    
end
