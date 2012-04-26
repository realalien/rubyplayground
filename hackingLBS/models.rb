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
        puts "[INFO] DianpingPageParser#shops_in_page(#{url})...begin"
        m.get(url) do |page|
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
        end
        puts "[INFO] DianpingPageParser#shops_in_page...end"
        return shops
    end
	
	# TODO: handle the pagination
    def self.members_in_page(url)
        members  = []
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        puts "[INFO] DianpingPageParser#members_in_page(#{url})...begin"
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
    def reviewed_shops
        shops = DianpingPageParser.shops_in_page reviews_url
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
    def address_from_dianping
        
    end
    
end
