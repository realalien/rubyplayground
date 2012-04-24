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


    def link=(link)
        @link = link;
        #@name = link.text || ""
    end
    
    def link
        return @link;
    end
=end
    
    def ==(another)
        @dianping_id == another.dianping_id
    end

end


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
        members = []

        $b.get(self.url_checkins) do |page|
            page.links.each do |link|
                if link.href =~ /\/member\/[0-9]+$/
                    #one = Member.created_from_link(link)
                    
                    #one = Member.create(:dianping_id => File.basename(link.href),
                    #                    :name => link.text)
                    #one.link = link
                    
                    one  = Member.new
                    one.dianping_id = File.basename(link.href)
                    one.name = link.text
                    one.link = link
                    
                   if members.include?(one)
                       #TODO:DIG: sniff for more refined data.
                       #if one.is_refined?
                           # TODO: replace or update the old data.
                       #end
                       
                       #experimental, refine the name of the member
                       old_index = members.find_index one
                       #puts old_index
                       if old_index != nil
                           # puts members[old_index].name
                           if members[old_index].name.empty? && !one.name.empty?
                               members[old_index].name = one.name #TODO: not replace, keep logging.
                               puts "Updating member's name...from: [#{members[old_index].name}] to #{one.name}"
                           end
                       end
                   else
                       #puts "[INFO] found new member: %d", 
                       members << one
                   end 
                end
            end
        end

        return members
    end
end
