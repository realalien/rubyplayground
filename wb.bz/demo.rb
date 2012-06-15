#encoding:UTF-8

require 'grizzly'
require 'mongoid'
require 'open-uri'
# note: couple with the server side to persistence some information to cut down the number of api requests


# TIP: use web app to get a temporary access token
access_token = "2.00oO1cSBga_djDe8f4124d31dD2H3E"
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
    
    embeds_many :tag_category
end


class TagCategory
    include Mongoid::Document
    
    field :name, type: String
    # field :tags, type: Array   # use embeded document
    
    index({ name: 1 }, { unique: true, name: "tag_category_name_uniq_idx" })
    
    embeds_many :tag_info
    embedded_in :weibo_user
end
 

class TagInfo
    include Mongoid::Document
    
    
    field :source, type: String   # where the data is retrieved
    # field 
    include Mongoid::Timestamps::Updated
    
    embedded_in :tag_category
end


# workload here!
# IDEA: 
class AutoTaggingBot
    
    JOB_CATEGORY = "jobs"
    
    # IDEA: actually user's data or user's status update can be 
    # for simple demo, we only check the description in user's data.
    def self.tag_user_jobs_with_jobname(user, jobname)
        if user.screen_name.include? "#{jobname}"
            target_user = WeiboUser.find user.id
            puts  target_user.nil? ? "YES " : "NO"
            if  target_user.nil?
                puts "[INFO] Going to persistent user to local db"
                remote_user = $client.user_show user.id
                target_user = WeiboUser.new( JSON.parse(remote_user.data.to_json) )
                
                # add one TagCategory
                category = TagCategory.new( :name =>JOB_CATEGORY)                
                # add one TagInfo
                tag = TagInfo.new(:name => jobname, :source => "user data description." )        
                # assembly
                category.tag_infos << tag
                target_user.tag_categories << category
                target_user.save!
                
            else  # user exists
                # see if has job category
                puts "[INFO] User is already in the database local db"
                cate = target_user.tag_categories.where(:name => JOB_CATEGORY)
                
                if cate.nil?
                    cate = TagCategory.new( :name =>JOB_CATEGORY)
                    target_user.tag_categories << cate
                end
                
                tag = cate.tag_infos.where( :name => jobname)
                if tag.nil?
                    cate.tag_infos << tag
                else
                    puts "[INFO] #{tag.name} has been added already!"
                end
                
                target_user.save!
            end
            puts "[INFO] Tagging job #{jobname} in th for user '#{user.screen_name}' (id:#{user.id})"
            $COUNT += 1
        else
            puts "[INFO] Not found job #{jobname} in the description of user '#{user.screen_name}' (id:#{user.id})"
        end
    end
    
    
    
end



Mongoid.configure do |config|
    name = "mongoid_weibo_dev"
    host = "localhost"
    port = 27017
    config.database = Mongo::Connection.new.db(name)
end


if __FILE__ == $0
    #user = $client.user_show_by_screen_name("realalien")
    #find_bifriends_geo_distribution(user.id)
    
    user = $client.user_show_by_screen_name("csdn")
    puts user.description
    users = $client.friends(user.id)
    
    jobname = "CSDN"
    
    #AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
    
        while users.next_page? #Loops untill end of collection
            users.each do | user|
                AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
            end
        end
    
    puts "Total number of people whose jobname contains #{jobname} and in friendship with #{user.name}(id: #{user.id})"
    puts $COUNT

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
