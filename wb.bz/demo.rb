#encoding:UTF-8


require File.join(File.dirname(__FILE__),"./util.d/weibo_client.rb")

# note: couple with the server side to persistence some information to cut down the number of api requests


# TIP: use web app to get a temporary access token

# --------------------------------------------

=begin
# Simplify the api for irb use.
# NOTE: following http://www.ibm.com/developerworks/opensource/library/os-dataminingrubytwitter/index.html#ruby_tour
user = $client.user_show_by_screen_name("realalien")
puts user.location
puts user.province
puts $client.friends(user.id).first.name

=end


# --------------------------------------------
# Web page crawling for statuses under a topic. Because the web service is not open and requires contract

#require File.join(File.dirname(__FILE__),"./util.d/scraper.rb")

#page = retrieve_page()









# --------------------------------------------
# find parents who educate their children with music instruments, better if find a teacher!




# --------------------------------------------

# Sometimes, information is not very direct until two or more attributes are input ( a femail,  has offspring's pictures) is a mother, so more information could be extracted, like parenting, way of doing things, her data input and life stream(if in a 3D game, we can simulate that.)
class KnowledgeableBot
    
    
end


# search for douban or dianping and other 
class CrossSnsAgent
    
end


class KnowMoreAbout
    
    def self.organization_circles(user)
        # NOTE: if the organization is not specified personally, there are many ways to infer the information from many related data, it's a problem of probablity of correctness or depth of personal openness. Think it as  circles.
        
        
    end


    def self.is_serious
        puts "#{users.comments_distribution_on_a_weibo_account_graphically}" # best case, worst case. random comment?
        return 
    end
    
end 



if __FILE__ == $0
    
    
    # ------------------------------------------   
    # fun with user comment
    
    # group comment by geo
    # TODO: find the efficient way for grouping data based on related models(commentors' sex, geo, jobs, educations ).
     
    # --> get user's status
    #user = $client.user_show_by_screen_name("何帆")
    #puts user.inspect
    #user.status                                # latest status
    #sts = $client.statuses(user.id)             # last few status, a cursor!
    # --> get all comments from one status of the target user
    
    
    # ------------------------------------------
    # Try to extract more information from one person, should leaving interface for future incoming data of interest.
    # NOTE: usually this kind of information is manually produced from human intervention for notes on viewing images (we can deduce a user's has child from images)
    
    # ------------------------------------------
    # persons of interest, search path:
    # ==> current user location  ( GIS module )
    #     Q: how for a local script?  A:
    # ==> landmarks ( GIS module )
    #     Q: how for a local script?  A:
    # ==> organization with landmark address (Organization cateogorying, )
    # 
    # ==> 
    # ==> close path ( Result evaluting)
    
    
    
    
    
    # ------------------------------------------
    # make fun of people in "Beijing Hai Dian"
    
    # ------------------------------------------
    # Goal: map out the innovation parks in very major city, try to be automatic!
    
    # ------------------------------------------
    # Goal: seeking the most power persons among fans of the weibo user  
    # EXP:  I think it will be great if the process(selecting, filtering, etc) is recorded and the input and output result is judge.
    # sth. like   target "find potential leader"  do ;   ;end
    
    # ------------------------------------------
    # Goal: tapping into the gossips among university students
    
    
    # ------------------------------------------
    # Goal: find the offspring of people in power
    
    
    # ------------------------------------------
    # TODO: indexing/cataloguing the products and organizations
    
    

    
   
    # ------------------------------------------------- province city data
    #  province city test
    #r = province_city_name(31,1000)
    #puts r.inspect
    
    
    # ------------------------------------------    
    # find related persons of target organization, confirmed by person's bilateral friends
    # HINT: the potential hacking could be distill some conversations among people, extract insiders' info., or find more related persons, etc.
    # PURPOSE: for biz, for education resources and for public sector
    # NOTE:here we only through weibo's organizations, no other services
    
    
    
    
    # IDEA: SYNTHSIZE WITH hackingLBS
    # i.e. we can estimate the probablity of personal presence in an specific area by find his/her data from Dianping, jiepang or other LBS service which offer public data.
    
    
    
    
    # IDEA: SYNTHEISZE WITH news.tracker,
    # i.e. org in news---> people in weibo groups(of that org, including their roles and other roles missing???)
    
    # organizations l
    
    
    # ------------------------------------------ 
    #  create a theory hypothesis 'upper layers' and test them with different aspects of data.
 
end


    # ------------------------------------------
=begin

# IDEA: how to make it pluggable to allow several permutations of conditions, so machine can also eliminate the possiblilities of idiot-alike guessing!
module SNS
  module Mining
    module User 

    end
  end
end


hypothesis "user is an advertisement account" do 
    
end

    # ------------------------------------------ 
# IDEA: it looks like we must separate/generalize the individual intentions by deducing from evidence of behaviors
hypothesis "user may try to hide default location"  do 
    # IDEA: should pass through following test cases to return yes.
    
    patttern "not fall in the most friends geo dist"  do
        user.location != find_friends_geo_distribution[0] 
    end
    
    anti_pattern "study or work aboard" do 
        
    end
    
    # case-studies.each do { |case| case.passed? }  # 
    # IDEA: some criteria may not assert the trueness, but may help to increase the probablity of a guessing. Be aware!
    # e.g. too many or too less friends will render guess too wild.

end



=end
