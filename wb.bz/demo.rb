

require 'grizzly'

# note: couple with the server side to persistence some information to cut down the number of api requests


# TIP: use web app to get a temporary access token
access_token = "2.00oO1cSBga_djD48e947640ew8nzWB"
$client = Grizzly::Client.new(access_token)


puts $client  #.methods.sort



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
    
    
    puts "Total:  #{friends.count}"
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





if __FILE__ == $0
   find_bifriends_geo_distribution(1191241142)
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
