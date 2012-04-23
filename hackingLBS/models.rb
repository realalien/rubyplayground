require 'rubygems'
require 'mechanize'  # this should be wrapped in one place, e.g. util class. Q: do we need to do the require?
require 'pp'

$DIANPING_BASE_URL = "http://www.dianping.com/"

$b = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
}


class Explorable
    # MongoMapper's 
    include MongoMapper::Document
    key :dianping_id, String, :required => true
    key :name, String
    
    attr_accessor :dianping_id, :name   #, :link
    
    def initialize(dianping_id)
		self.dianping_id = dianping_id
    end

    def link=(link)
        @link = link;
        @name = link.text || ""
    end
    
    def link
        return @link;
    end

    def ==(another)
        @dianping_id == another.dianping_id
    end
end


# TODO: some comparison methods 

class Member < Explorable
  
    # Create member instance from member id observed, for the cases that the user is not created from other Dianping data.

    def self.created_from_link(link)
        id_in_link = File.basename(link.href)
        one = Member.new id_in_link
        one.link = link;
        # IDEA: update record logging for history tracking here!
        return one
    end
end

class MemberFinder

end


# ======================================================================================


# NOTE: For now, it's only model after shops of 'dianping.com', mainly according to the observable information.

#

# TODO: experiment
class UpdateLogging
    include MongoMapper::EmbeddedDocument
    
end

class Shop  < Explorable
    
    # Create member instance from member id observed, for the cases that the user is not created from other Dianping data.
    def self.created_from_link(link)
        id_in_link = File.basename(link.href)
        one = Shop.new id_in_link
        one.link = link;
        # IDEA: update record logging for history tracking here!
        return one
    end

    # Find a list of people via checkin pages.
    def find_people_via_checkins
        members = []
        query_path = File.join(self.link.href, "gone");  #TODO: move to a central place for managing and cont. updating.
        p query_path

        b = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }

        query_link = File.join($DIANPING_BASE_URL, query_path)   #TODO: refactor, move it class level.
        p query_link

        $b.get(query_link) do |page|
            page.links.each do |link|
                if link.href =~ /\/member\/[0-9]+$/
                   one = Member.created_from_link(link)
                   if members.include?(one)
                       #TODO:DIG: sniff for more refined data.
                       #if one.is_refined?
                           # TODO: replace or update the old data.
                       #end
                       
                       #experimental, refine the name of the member
                       old_index = members.find_index one
                       puts old_index
                       if old_index != nil
                           puts members[old_index].name
                           if members[old_index].name.empty? && !one.name.empty?
                               old.name = one.name #TODO: not replace, keep logging.
                           end
                       end
                   else 
                       members << one
                   end 
                end
            end
        end

        p "==========="
        p "Total:  #{members.size}"
        return members
    end
end
