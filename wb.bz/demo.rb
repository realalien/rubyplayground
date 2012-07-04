#encoding:UTF-8

require 'grizzly'
require 'mongoid'
require 'open-uri'
# note: couple with the server side to persistence some information to cut down the number of api requests


# TIP: use web app to get a temporary access token
access_token = "2.00oO1cSBga_djD5bf2e642650N_6pw"
$client = Grizzly::Client.new(access_token)


puts $client  #.methods.sort

$COUNT=0

# we use id rather than object because  User class may be not pinned to a speicific class.
def find_friends_geo_distribution(user_id)
    
    geo_dist = {}
    if user_id.is_a? Numeric   # allow a single user id
        friends = $client.friends(user_id)
        
        while friends.next_page? #Loops untill end of collection
            friends.each do |friend|
                #... # Loops 50 times
                if  not friend.province.empty? and not friend.city.empty?
                    if geo_dist[friend.province+":"+friend.city].nil?
                        geo_dist[friend.province+":"+friend.city] = 1
                    else
                        geo_dist[friend.province+":"+friend.city] += 1
                    end
                end
            end
        end 

    end
   
    geo_dist = geo_dist.sort_by{|key, value| value}.reverse  

    geo_dist.each do | geo_cnt |
		puts "#{geo_cnt[0]}  #{geo_cnt[1]}"
	end
    #geo_dist.each_pair do | k,v|
    #    puts "#{k} .... #{v}" 
    #end
end


# we use id rather than object because  User class may be not pinned to a speicific class.
def find_bifriends_geo_distribution(user_id)
    
    geo_dist = {}
    if user_id.is_a? Numeric   # allow a single user id
        friends = $client.bilateral_friends(user_id)
        
        while friends.next_page? #Loops untill end of collection
            friends.each do |friend|
                #... # Loops 50 times
                if  not friend.province.empty? and not friend.city.empty?
                    if geo_dist[friend.province+":"+friend.city].nil?
                        geo_dist[friend.province+":"+friend.city] = 1
                    else
                        geo_dist[friend.province+":"+friend.city] += 1
                    end
                end
            end
        end 
        
    end
    
    geo_dist = geo_dist.sort_by{|key, value| value}.reverse  
    
    geo_dist.each do | geo_cnt |
		puts "#{geo_cnt[0]}  #{geo_cnt[1]}"
	end
    #geo_dist.each_pair do | k,v|
    #    puts "#{k} .... #{v}" 
    #end
    poi_user = $client.user_show user_id
    puts poi_user.inspect
    
    # sum of aggregate users by province
    provices_bi_count = {}
    geo_dist.each do | prov_city |
        prov, city = prov_city[0].split ":"
        if provices_bi_count[prov].nil?
            provices_bi_count[prov] = prov_city[1]
        else
            provices_bi_count[prov] += prov_city[1]
        end
    end
    
    sorted_provices_bi_count = provices_bi_count.sort_by{|key, value| value}.reverse 
    
    
    # Geo Util
    province_with_most_bifriends, city_with_most_bifriends =  
    inSameCity = (poi_user.province.to_i == province_with_most_bifriends && poi_user.city == city_with_most_bifriends ) 
    inSameProvince = (poi_user.province == sorted_provices_bi_count[0][0])
    
    
    puts "Total:  #{friends.total_items}"
    puts "Bilateral friends count by city: #{geo_dist}"
    puts "Bilateral friends count by province: #{sorted_provices_bi_count}"
    puts "------------------------"
    puts "Q: if user location is among his/her bilateral frineds'"
    puts "inSameCity  ... #{inSameCity}"
    puts "inSameProvince  ... #{inSameProvince}"
    he_or_she = poi_user.gender == 'm'? 'He ': 'She '
    his_or_her = poi_user.gender == 'm'? 'his ': 'her '
    puts "A: So ... #{he_or_she} is #{(inSameCity || inSameProvince) ? '': 'not '} among #{his_or_her} bilateral friends ."
    puts "------------------------"
end



# EXP: persistent, different tagging(e.g. job, role)

# TODO: add a log when created/updated in db

# NOTE: this class stands for the weibo accounts those have been saved to local database
class WeiboUser
    include Mongoid::Document
    

    include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
    
    embeds_many :tag_categories
end


class WeiboUserManager
   
    # TODO: actually a single tagging process, we query the local db multiple times, tune it please!
    # TODO: see this class can also do some sanity checking.
    def self.tag_user_with_category_and_tags(user, category_name, tags, *opt)
        begin
            target_user = WeiboUser.find(:id => user.id)
            puts  target_user.nil? ? "YES " : "NO"
            puts target_user.inspect
            
            # no exception thrown, should find one 
            # see if has job category
            puts "[INFO] User is already in the database local db"
            cate = target_user.tag_categories.find(:name => category_name)
            
            if cate.nil?
                cate = TagCategory.new( :name => category_name)
                target_user.tag_categories << cate
            end
            
            
            tags.each do | t | 
                tag = cate.tag_infos.where( :name => t)  # TODO: bugs here!
                if tag.nil?
                    cate.tag_infos << tag
                else
                    puts "[INFO] #{t.name} has been added already!"
                end
            end
          
            target_user.save!
        rescue Mongoid::Errors::DocumentNotFound
            puts "[INFO] Going to new and persistent user to local db"
            remote_user = $client.user_show user.id  # TODO: seem already a valid weibo user here.
            target_user = WeiboUser.new( JSON.parse(remote_user.data.to_json) )
            
            puts target_user.inspect
            # add one TagCategory
            category = TagCategory.new( :name => category_name)                
            # add one TagInfo
            
            tags.flatten.each do | t |
                tag = TagInfo.new(:name => t, :source => opt["source"] || "not specified" , :is_manual => (opt["is_manual"] == true ? true: false ) )        
                # assembly
                category.tag_infos << tag
            end
            
            puts category.inspect
            target_user.tag_categories << category
            target_user.save!
            puts target_user.inspect
        end 
    end
end

class TagCategory
    include Mongoid::Document
    
    field :name, type: String
    # field :tags, type: Array   # use embeded document
    
    index({ name: 1 }, { unique: true, name: "tag_category_name_uniq_idx" })
    
    embeds_many :tag_infos
    embedded_in :weibo_user
end
 

class TagInfo
    include Mongoid::Document
    
    
    field :source, type: String   # where the data is retrieved
    field :is_manual, type:Boolean 
    include Mongoid::Timestamps::Updated
    
    embedded_in :tag_category
end


class Organization
    include Mongoid::Document 
    
    
    field :full_name, type: String
    field :short_name, type:String
    
    def self.is_public_sector
        return false ; #true if 
    end

    
    
end

# workload here!


# For now, it's a CLI processor
class ManualTagger
    
    @@allowed_tag_categories = ["jobs", "pois"]
    @@repo = {}
    @@user = ""
    
    def self.ask_for_user_to_be_tagged
        print "Please input the target user's weibo id or screen_name(enter to stop): "
        name_or_id = $stdin.gets.chomp

        # suppose id first, then screen id
        begin
            user = $client.user_show name_or_id
            puts user.inspect
            
            @@user = user  # tempory keeping
            @@repo[user.id] = {} 
            self.ask_for_tag_category
            #return user
        rescue Grizzly::Errors::WeiboAPI  # not found, 20003
            begin 
                user = $client.user_show_by_screen_name name_or_id
                puts user.inspect
    
                @@user_id = user.id 
                @@repo[user.id] = {}
                self.ask_for_tag_category
                #return user
            rescue Grizzly::Errors::WeiboAPI
                return  # more than we can/will handle
            end
        ensure 
            #return
        end
    end
    
    def self.ask_for_tag_category
        print "Please input a tag category(enter to stop): "
        
        # keep asking for a non empty string
        while ((name =  $stdin.gets.chomp).empty? or  not @@allowed_tag_categories.include?(name) )
            puts "'#{name}' is either empty or not in the categories allowed to be added! Input again:"
            # TODO: since it's a manual process, we should require the input to be well formatted and reinput for confirmation
        end

        @@repo[@@user.id]["tag_category"] = name
        puts @@repo.inspect

        self.ask_for_tag_info
    end


    def self.ask_for_tag_info
        tags = []
        print "Please input tags(separated by blankspaces, enter to stop): "
        
        until (name =  $stdin.gets.chomp).empty?
            # parse the input
            tags << name.split(/\s+/)
        end

        puts tags
        # actually we can only process on tag_category at a time, no need for '["tag_category"]["tags"]'
        @@repo[@@user.id]["tags"] = tags

        puts @@repo


        print "Finally, where do you get this info(enter to stop): "
        @@repo[@@user.id]["source"] =  $stdin.gets.chomp

        self.manual_tagging(@@user,@@repo[@@user.id]["tag_category"],@@repo[@@user.id]["tags"])
    end

    
    def self.manual_tagging(user, tag_cate, tags)
        puts @@repo

        # persist
        WeiboUserManager.tag_user_with_category_and_tags(user, tag_cate, tags, { :is_manual => true, :source =>  @@repo[@@user.id]["source"]})


        # clean
        @@repo.delete @@user.id
    end
end






# IDEA: because there are many ways of categorizing data, think the tagging process of 'text' way of categorying data. 
#    (AFM: research paper to support the tagging behavior and practice".  
#    Besides the tagging, another way of categorizing data is to have some kind of manager or artificial library do the 
#    booking keeping of all data(it goods at aggregating data, but may not be versatile to deal with changes).
class AutoTaggingBot
    JOB_CATEGORY = "jobs"
    
    # IDEA: actually user's data or user's status update can be 
    # for simple demo, we only check the description in user's data.
    def self.tag_user_jobs_with_jobname(user, jobname)
        if user.description.include? "#{jobname}"
            puts user.screen_name
    
            
            
            puts "[INFO] Tagging job #{jobname} in th for user '#{user.screen_name}' (id:#{user.id})"
            $COUNT += 1
        else
            puts "[INFO] Not found job #{jobname} in the description of user '#{user.screen_name}' (id:#{user.id})"
        end
    end
end


# Sometimes, information is not very direct until two or more attributes are input ( a femail,  has offspring's pictures) is a mother, so more information could be extracted, like parenting, way of doing things, her data input and life stream(if in a 3D game, we can simulate that.)
class KnowledgeableBot
    
    
end

class AutoTellingBot
    def self.find_weibousers_with_jobname(jobname)
        users = []
        query = WeiboUser.where( "tag_categories.tag_infos.name" => jobname)
        query.each do | u |
            users << u
        end
        puts users.inspect
    end
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

Mongoid.configure do |config|
    name = "mongoid_weibo_dev"
    host = "localhost"
    port = 27017
    config.database = Mongo::Connection.new.db(name)
end


if __FILE__ == $0
    
    
    # EXP: Tagging Test
    #ManualTagger.ask_for_user_to_be_tagged
    
    # Try to extract more information from one person, should leaving interface for future incoming data of interest.
    # NOTE: usually this kind of information is manually produced from human intervention for notes on viewing images (we can deduce a user's has child from images)
    
    
    
    
    # persons of interest, search path:
    # ==> current user location  ( GIS module )
    #     Q: how for a local script?  A:
    # ==> landmarks ( GIS module )
    #     Q: how for a local script?  A:
    # ==> organization with landmark address (Organization cateogorying, )
    # 
    # ==> 
    # ==> close path ( Result evaluting)
    
    
    
    
    
    
    # make fun of people in "Beijing Hai Dian"
    
    
    # Goal: map out the innovation parks in very major city, try to be automatic!
    
    
    # Goal: seeking the most power persons among fans of the weibo user  
    # EXP:  I think it will be great if the process(selecting, filtering, etc) is recorded and the input and output result is judge.
    # sth. like   target "find potential leader"  do ;   ;end
    
    
    # Goal: tapping into the gossips among university students
    
    
    # Goal: find the offspring of people in power
    
    
    # TODO: indexing/cataloguing the products and organizations
    
    
    # IDEA: each requirement should be able to mapped to an array of attributes ( also help to increase the probability of accuracy), e.g. the 
    
    
    
    #user = $client.user_show_by_screen_name("flyerlemon")
    #find_bifriends_geo_distribution(user.id)
    
    
=begin    
    #user = $client.user_show_by_screen_name("realalien")
    #find_bifriends_geo_distribution(user.id)
    
    user = $client.user_show_by_screen_name("csdn")
    puts user.description
    users = $client.friends(user.id)
    
    jobname = "CEO"
    
    #AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
    #while users.next_page? #Loops untill end of collection
    #    users.each do | user|
    #       AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
    #    end
    #end
    
    AutoTellingBot.find_weibousers_with_jobname "CEO"
    
    puts "Total number of people whose jobname contains #{jobname} and in friendship with #{user.name}(id: #{user.id})"
    puts $COUNT
=end
 
=begin    
    # persistent test
    user = $client.user_show_by_screen_name("realalien")
    user_data =  user.data.to_json
    puts "---------------"
    puts user_data
    WeiboUser.create( JSON.parse(user_data) )

    u1 = WeiboUser.find user.id
    puts "--------------- u1"
    puts u1
    
    puts "ready to tagg it to the user:" + user.screen_name
    t = Taggable.new( :tag_category_name => "job", :tags => ["programmer", "project maintainer" ] )
    u1.taggables << t 
    u1.save!
=end
    
    
 
end

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
