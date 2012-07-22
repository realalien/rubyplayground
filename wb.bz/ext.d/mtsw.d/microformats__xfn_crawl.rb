#encoding:UTF-8

require 'yargi'
require 'set'
require File.join(File.dirname(__FILE__),"../../util.d/scraper.rb")
#Q: how do I do the visualization?
#HINT: is it a good one? http://ruby.about.com/od/tasks/ss/Making-Digraphs-In-Ruby.htm
#A: 


# TODO: what if some attributes(tag/mark) is added/modified, then how to compare?
# HINT: shall we do a selection to warn the users?

class Yargi::Digraph
    
    def get_node( item_in_hash_with_uid )
        raise "to get a node, one mush feed a hash with key :uid" unless item_in_hash_with_uid.has_key? :uid
        
        @vertices.each do |v|
            if v[:uid] == item_in_hash_with_uid[:uid]
                return v 
            end
        end
        # not find , create a new one
        return self.add_vertex(item_in_hash_with_uid)
        
    end
    
    def has_node(item_in_hash)
        raise "to test a node's existence, one mush feed a hash with key :uid" unless item_in_hash.has_key? :uid
        @vertices.each do |v |
            if v[:uid] == item_in_hash[:uid]
                return true 
            end
        end
        return false
    end
end



if __FILE__ == $0

#ARGV.each do|a|
#  puts "Argument: #{a}"
#end


$ROOT_URL = ARGV[0]

if ARGV.size > 2
	$MAX_DEPTH = ARGV[1].to_i
else
	$MAX_DEPTH = 1
end


$XFN_TAGS = Set.new [ 'colleague',
               'sweetheart', 'parent', 'co-resident',
               'co-worker', 'muse', 'neighbor', 'sibling', 'kin', 'child', 'date', 'spouse', 'me', 'acquaintance', 'met',
               'crush', 'contact', 'friend' ]
OUT = "graph.dot"

    
depth = 0
    
g = Yargi::Digraph.new
    
next_queue = [$ROOT_URL]
    
while depth < $MAX_DEPTH && next_queue.size > 0
    depth += 1
    queue, next_queue = next_queue, []
    puts "====>  queue : #{queue.inspect}"
    queue.each do | item |  # item: a webpage/link of a person?

        page = retrieve_content(item)
        anchor_tags = page.links
    
        if not g.has_node( {:uid => item} )
            root = g.add_vertex :uid => item
            root.add_marks(:label => item )
        end
        
        
        anchor_tags.each do | a |
            if a.rel.size > 0
                if ( Set.new(a.rel)  & $XFN_TAGS ).size > 0
                    friends_url = a.href
                    e = g.add_edge( g.get_node(:uid => item), tmp = g.get_node(:uid => friends_url )  )
                    
                    e.add_marks( :label => a.rel )
                    tmp.add_marks( :label => a.text )
                    
                    next_queue << friends_url
                end    
            end
        end
        
    end  # of each item
    
    
    # write out to file
    File.open("xfn_ajaxian.dot", "w")do |f |
        f.puts g.to_dot
    end

    #debug
    puts g.to_dot
    puts "graph : #{g.inspect}"
end  # of while


end  # if __FILE__ == $0

# to make the graph into png:  `circo -Tpng -Oxfn_ajaxian xfn_ajaxian.dot`
# NOTE: use `sudo port install graphviz' to install graphvis rather than from .pkg or from brew which have linking problems.

