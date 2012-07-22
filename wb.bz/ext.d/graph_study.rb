#encoding:UTF-8
require File.join(File.dirname(__FILE__),"../util.d/weibo_client.rb")


# Graph study along with 'Mining social web'(python version )

# e.g. tweet that was reposted by many 
# 视觉艺术：【街头艺术】《Hold Me》，位于波兰，作者Adam Łokuciejewski及Szymon Czarnowski。( status id: 1649769582 )
# id"=>3466187629912291, "mid"=>"3466187629912291", "idstr"=>"3466187629912291", "text"=>"【街头艺术】《Hold Me》，位于波兰，作者Adam Łokuciejewski及Szymon Czarnowski。" .... reposts_count"=>161, "comments_count"=>14,


#user = $client.user_show_by_screen_name "视觉艺术"
#puts user.id   #  => 1649769582

# NOTE: first is the earliest. It's not the latest one!!
# f = $client.statuses(user.id).first.id    # puts f  # => 3461128711934510


#reposts = $client.reposts "3466187629912291"

#while reposts.next_page?
#    reposts.each_with_index do | r,idx|
#        puts r.inspect
#        break if idx > 3
#    end
#    break
#end



# NOTE:TODO: retweet graph should be generated after a period of time(may be one day later after the posting of the most original tweet), otherwise the distribution analysis will lose many nodes for analyzing.
# NOTE:Q: instead of randomly selecting a topic and find connected user
#   What are the scenarios for using the graph to analysis 
#    e.g.? analysis the influence of a user, rt and rt .... counting.

# HYPO:  
# STEP: 


# -----------------------------

require 'yargi'
graph = Yargi::Digraph.new

=begin   
# hands on yargi gem
v1 = graph.add_vertex(:kind => "simple vertex")
v2 = graph.add_vertex(:kind => "simple vertex")
v3 = graph.add_vertex(:kind => "simple vertex")
v4 = graph.add_vertex(:kind => "simple vertex")

graph.add_edge(v1,v2)
graph.add_edge(v1,v3)
graph.add_edge(v1,v4)
graph.add_edge(v2,v3)
graph.add_edge(v2,v4)

puts graph.vertex_count
puts graph.edge_count
=end



=begin
#IDEA: use graph to analysis the people/organization relationship, 
#      e.g. test if influence is reinforced in people with the same education background.
=end




=begin 
# MSW, p.13, 
# TODO: apply 'power rule' analysis in different scenarios.
 
# STEPS:  ==> collect tweets among friends 
          ==> count retweets and create graph(nodes as one's friends, edge as conversations ) 
          ==> DEDUCE: active friendships among one's friends.
 
# STEPS:  ==> collect tweets from most reposts
          ==> 
 
# Q: what's the graph usage in real world? 
# A: 
=end




