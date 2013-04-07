require 'rubygems'
require 'mechanize'  # this should be wrapped in one place, e.g. util class. Q: do we need to do the require?
require 'pp'
require 'active_support'

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




# Deprecated: the twitters on sina weibo.com is injected via javascript, rather than static web page. This class might be useful in finding weibo user links in static webpages
# ATTENTION: not test yet!
# NOTE: It's only gather information by parsing the webpage.
# This may only served as a comparison with the weibo API call which is more efficient.
class SinaWeiboPageParser
    
    # TODO: should allow caller method to use block to give sth in handling errors.
    def self.safeguard_page_retrieve(url)
        page = nil
        #DianpingPageParser.rest_to_avoid_page_forbidden
        begin
            m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
            }
            page = m.get(url) 
        rescue => e 
            puts "[Error] retrieving #{url} "
            puts e.message
            puts e.backtrace
            $ACCUMULATED_DELAY += 1
            puts "[WARNING] Compulsory put programming into sleep due to page retrieval error. Back to work in #{$ACCUMULATED_DELAY} minute(s)"
            sleep $ACCUMULATED_DELAY
            
            # just return an empty Mechanize::Page
            page =  Mechanize::Page.new
        ensure
            $TOTAL_PAGE_REQUEST += 1
            return page
        end
    end

    # TODO: handle the pagination
    def self.users_in_page(url)
        users = []
        
        user_id_regex = /^http:\/\/weibo.com\/u\/[0-9]+$/            # e.g.  http://www.weibo.com/u/2641707997
        user_name_regex  = /^http:\/\/www.weibo.com\/n\/[[:print:]]$/  # e.g.  http://www.weibo.com/n/_%E9%98%BF%E7%89%9B_, http://www.weibo.com/n/virtualTomato
        user_name_regex2 = /^http:\/\/weibo.com\/[[:alnum:]]$/          # e.g.  http://www.weibo.com/hzqixiang


        weibo_account_regexes = [ user_id_regex, user_name_regex, user_name_regex2 ];

        #puts "[INFO] DianpingPageParser#shops_in_page...begin (#{url})"        
        page = SinaWeiboPageParser.safeguard_page_retrieve url
        puts "Page retriving ....Done!"
        # First page of personal review, also find the pagination.
        #puts page
        page.links.each do | link |
            # find potential user link
            puts ".........................#{link}"
            weibo_account_regexes.each do | regex |
                 if link.href =~ regex
                     puts "Found user account, link  [#{link}]"
                     break;
                 end 
            end 
            
            #if link.href =~ /\/shop\/[0-9]+$/ 
            #    #p s
            #    shops << s  # Shop.created_from_link(link)  
            #end
        end

        # shops in other pages


        #puts "[INFO] DianpingPageParser#shops_in_page...end"
        #return shops
    end
end

# Options:
# * :tries - Number of retries to perform. Defaults to 1.
# * :on - The Exception on which a retry will be performed. Defaults to Exception, which retries on any Exception.
#
# Example
# =======
#   retryable(:tries => 1, :on => OpenURI::HTTPError) do
#     # your code here
#   end
#
def retryable(options = {}, &block)
    opts = { :tries => 1, :on => Exception }.merge(options)
    
    retry_exception, retries = opts[:on], opts[:tries]
    
    begin
        #puts "before yield retries....#{opts[:tries] - retries + 1}"
        yield
        #puts "after yield"
    rescue   retry_exception => e
        puts "[Error] retrieving #{url} at request No. #{$TOTAL_PAGE_REQUEST}"
        #puts e.message
        #puts e.backtrace
        $ACCUMULATED_DELAY += 4
        puts "[WARNING] Compulsory put programming into sleep due to page retrieval error. Back to work in #{$ACCUMULATED_DELAY} minute(s)"
        sleep $ACCUMULATED_DELAY
        
        # just return an empty Mechanize::Page
        #page =  nil
        puts "[WARNING] Exception occurred! retry ... #{retries}"
        retry if (retries -= 1) > 0
    end
    
    yield
end


class DianpingPageParser
    
    # TODO: should allow caller method to use block to give sth in handling errors.
    def self.safeguard_page_retrieve(url)
      retryable(:tries => 3, :on => { :return => nil }) do   # :exception => Mechanize::ResponseCodeError,
       #$TOTAL_PAGE_REQUEST += 1; puts "..........#{$TOTAL_PAGE_REQUEST}"
        
        page = nil
      begin      
        DianpingPageParser.rest_to_avoid_page_forbidden
         #begin
            m = Mechanize.new { |agent|
                agent.user_agent_alias = 'Mac Safari'
            }
  
            puts url
            page = m.get(url)
    
            return page
       rescue
            return nil
       end
      end
         # rescue => e 
    #   puts "[Error] retrieving #{url} at request No. #{$TOTAL_PAGE_REQUEST}"
    #  puts e.message
    #  puts e.backtrace
    # $ACCUMULATED_DELAY += 1
    #  puts "[WARNING] Compulsory put programming into sleep due to page retrieval error. Back to work in #{$ACCUMULATED_DELAY} minute(s)"
    #  sleep $ACCUMULATED_DELAY
            
    #   # just return an empty Mechanize::Page
    #  page =  nil
        #ensure
    # $TOTAL_PAGE_REQUEST += 1
            
    #     end
   
    end
    
    def self.rest_to_avoid_page_forbidden
         
        if $TOTAL_PAGE_REQUEST > 0 and $TOTAL_PAGE_REQUEST % 200 == 0
            puts "[INFO] Page requests reached #{$TOTAL_PAGE_REQUEST} ! Resting ......"
            sleep(($ACCUMULATED_DELAY + 1).minutes)
        end
    end

    # TODO: handle the pagination
    def self.shops_in_page(url)
        shops = []

        #puts "[INFO] DianpingPageParser#shops_in_page...begin (#{url})"        
        page = DianpingPageParser.safeguard_page_retrieve url

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
        

        #puts "[INFO] DianpingPageParser#shops_in_page...end"
        return shops
    end
	
	# TODO: handle the pagination
    def self.members_in_page(url)
        members  = []

        # puts "[INFO] DianpingPageParser#members_in_page...begin (#{url})"
        page = DianpingPageParser.safeguard_page_retrieve url
        
        if page
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
                            #puts "Updating member's name...from: [#{members[old_index].name}] to #{s.name}"
                        end
                    end
                else
                    #puts "[INFO] found new member: %d", 
                    members << s
                end                 
            end
        end 
        
        end
        #puts "[INFO] DianpingPageParser#members_in_page...end"
        return members
    end
	
    
    def self.number_of_pages(url_has_pagination) # use page to avoid multiple times of retrieving and parsing
        
        # NOTE: hint: reviews pagination is in <div class="Pages"/>,  
        # actually find all the  <a class='PageLink'>,  find the max one among innerText.

        #  * if there is a "<span class="PageMore">...</span>", then we can get the max page number by the next one in the all page links array
        #  * if there isn't a 'pagemore', the max page number is in the page link one ahead of 'next Page' 
        xpath = "//a[@class='PageLink']"
        #puts "[INFO] DianpingPageParser#number_of_pages...begin (#{url_has_pagination})"

        page = DianpingPageParser.safeguard_page_retrieve url_has_pagination

        if page 
            node_set = page.search(xpath)

            if node_set and node_set.length > 0 
                # collect all the inner text an 
                page_numbers = []
                node_set.each do | node|
                    page_numbers << node.inner_text.to_i
                end
                #puts "[DEBUG] #{page_numbers.sort.last} pages found."
                return page_numbers.sort.last
            else
                return 1  # only one page, no pagination
            end
        end
    end

    def self.get_one_item_from_xpath(xpath, page) # use page to avoid multiple times of retrieving and parsing
        if page and page.is_a? Mechanize::Page
            node_set = page.search(xpath)   #puts "node_set length : #{node_set.length} "
        end

        if node_set and node_set.length == 1
            value = node_set[0].inner_text
            return value
        else
            # TODO: halt and report!!!
            puts "[Error] Only one node is expected for xpath #{xpath} in page #{page.href}."
            return nil
        end
    end
    
    def self.structrued_address(shop_url)        
        page = DianpingPageParser.safeguard_page_retrieve shop_url
        
        if page
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
        else 
            return [nil, nil, nil]
        end
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
        num_of_pages = reviewed_pages 
        origin_pages = num_of_pages
        if num_of_pages >=2
            max_process_page_for_one_ip = 20
            if num_of_pages > max_process_page_for_one_ip  #TODO: should be configurable.
                num_of_pages = max_process_page_for_one_ip
                puts "[INFO] Member #{name}(#{url}) has #{origin_pages} pages of reviews."
                puts "[INFO] Because the limit of page views set up from the server side, guessing of location may not be accurate!"
                puts "[INFO] Around #{10*max_process_page_for_one_ip*1} out of #{origin_pages*10} reviewed shops are analysed."
            end
               
            (2..num_of_pages).each do | page_number |
                shops += DianpingPageParser.shops_in_page(File.join(reviews_url, "?pg=#{page_number}"))
            end
        end
        
        return shops
    end

    def reviewed_pages
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
        group_by_city_addrs = shops.collect{|shop| shop.address_dianping}.group_by {|element| element[0]}  # hashmap
        
        city_visits = group_by_city_addrs.map {|k,v| [k, v.length]}.sort_by {|k,v| v}.reverse   # array
        city_visits ||= []
        if city_visits.size > 0
            #puts "[DEBUG] city_visits sorted #{city_visits}"
            
            puts "[INFO] For member named: #{name}(#{url}) has #{shops.size} shop reviews ------"
            puts "[INFO] Most visited city is #{city_visits[0][0]} #{city_visits[0][1]}/#{shops.size} ratio:(#{city_visits[0][1] * 1.0/shops.size })"
            most_active_city = city_visits[0][0]
            
            # find most visited areas
            addrs_in_most_visited_city = group_by_city_addrs[most_active_city] # array of [city,district, address]
            # TODO: how to handle address without district?!
            # TODO: is it necessary to be objected-oriented?
            group_by_district_addrs = addrs_in_most_visited_city.group_by {|element| element[1]} 
            district_visits = group_by_district_addrs.map {|k,v| [k, v.length]}.sort_by {|k,v| v}.reverse   # array
            district_visits ||=[]
            if district_visits.size > 0
                #puts "[DEBUG] district_visits sorted #{district_visits}"
                puts "[INFO] Most visited district is #{district_visits[0][0]} #{district_visits[0][1]}/#{shops.size} ratio:(#{district_visits[0][1] * 1.0/shops.size })"
                most_active_district = district_visits[0][0]
            end
        else
            puts "[INFO] No shops reviewed by member named: #{name}(#{url})."
        end
        
        puts "[INFO] ---------------"
        
        return [most_active_city, most_active_district ]
        
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

    def url_gone
        return File.join(self.url, "gone")
    end

    def url_checkin
        return File.join(self.url, "checkin")
    end

    # Find a list of people via checkin pages.
    def find_people_via_checkins
        return DianpingPageParser.members_in_page url_checkins
    end

    # IDEA: we can check for difference in data of different 
    def address_dianping
        return DianpingPageParser.structrued_address url  #[cityname, district_name, No.&road]
    end


    def checkin_pages
        DianpingPageParser.number_of_pages url_checkin
    end


    def members_checked_in
        people = []
        # first page
        people += DianpingPageParser.members_in_page(url_checkin)
        # other pages
        num_of_pages = checkin_pages
        puts "[DEBUG] Shop #{name}(#{url}) has #{num_of_pages} pages of check-ins"
        if num_of_pages >=2
            max_process_page_for_one_ip = 20
            if num_of_pages > max_process_page_for_one_ip  #TODO: should be configurable.
                num_of_pages = max_process_page_for_one_ip
                puts "[INFO] Because the limit of page views at the server side, guessing of checked-in may not be accurate!"
                puts "[INFO] Around #{ (10*max_process_page_for_one_ip*1.0) / (checkin_pages*10)} members_checked_in are analysed."
            end
            
            (2..num_of_pages).each do | page_number |
                people_in_one_page= DianpingPageParser.members_in_page("#{url_checkin}?pageno=#{page_number}")
                people_in_one_page.each do | p|
                    people << p if not people.include? p
                end
            end
        end
        people = people.uniq
        #puts people.size
        return people
    end
    
end
