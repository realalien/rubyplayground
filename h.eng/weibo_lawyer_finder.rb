#encoding: UTF-9\8


require File.join(File.dirname(__FILE__),"../../wb.bz/util.d/weibo_client.rb")
# NOTE:
# * use file persistence for data reuse.
# * demo of explicit search logic path
# * try to use SNA tool


def attributes_with_keywords(weibo_user, attrs=[], keywords=[])
  
end


# Q: lawyers probably is a general role for many fields, e.g. civil legal, biz legal, etc.
#    try to distinguish/categorize them!
# A :
 
def collect_lawyers_from_weibo_user(screen_name)
  #  what to persist?  
  
  source_user = $client.user_of_screen_name(screen_name)
  
  # TODO: following code should be separated to avoid coupling. Find out how!
  # one is search logic, i.e. among bi-friends, from comments
  # the other is data filter logic, i.e. attributes with keywords inside, multiple bi-friends which are inside POI
  
  # intentions
  source_laywers_bilateral_friends = $client.bilateral_friends(source_user)
  # SUG: here there will be more people to select from if we select from just frineds.
  
  pois = []
  source_laywers_bilateral_friends.each do | f |
    if ( attributes_with_keywords(f, ["screen_name", "description"], ["lawyer", "律师"]) )
      pois << f
    end
  end
  
  pois.each do |p|
    puts "#{p.screen_name} (#{p.id}), #{p.description}"
  end
  
end



# IDEA: treat the existing users as discrete nodes, what the program should do is to map out the 



if __FILE__ == $0
  
  collect_lawyers_from_weibo_user()
end