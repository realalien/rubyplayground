#encoding:UTF-8


require 'google_chart'
require File.join(File.dirname(__FILE__),"../util.d/weibo_client.rb")
require File.join(File.dirname(__FILE__),"../util.d/weibo_const.rb")

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

    #geo_dist.each do | geo_cnt |
	#	puts "#{geo_cnt[0]}  #{geo_cnt[1]}"
	#end
    #geo_dist.each_pair do | k,v|
    #    puts "#{k} .... #{v}" 
    #end
end


# we use id rather than object because  User class may be not pinned to a speicific class.
def find_bifriends_geo_distribution(user_id)
    
    geo_dist = {}
    gender_dist = {}
    if user_id.is_a? Numeric   # allow a single user id
        #friends = $client.bilateral_friends(user_id)
         
        friends = $client.friends(user_id)

        while friends.next_page? #Loops untill end of collection
            friends.each do |friend|
                
                # gender categorization
                # NOTE: a female accout will soon get a lot of popularity just with some sexy photos, watch out for those evidences.
                if gender_dist[friend.gender].nil?
                    gender_dist[friend.gender] = 1
                else
                   gender_dist[friend.gender] += 1
                end
                
                # province/city categorization
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
    
    #geo_dist.each do | geo_cnt |
	#	puts "#{geo_cnt[0]}  #{geo_cnt[1]}"
	#end
    #geo_dist.each_pair do | k,v|
    #    puts "#{k} .... #{v}" 
    #end
    poi_user = $client.user_show user_id
    #puts poi_user.inspect
    
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
    province_with_most_bifriends, city_with_most_bifriends =  geo_dist[0][0].split(":") if geo_dist.size > 0
    #puts "------> #{province_with_most_bifriends.to_i} #{city_with_most_bifriends.to_i}"
    inSameCity = (poi_user.province.to_i == province_with_most_bifriends && poi_user.city == city_with_most_bifriends ) 
    inSameProvince = (poi_user.province == sorted_provices_bi_count[0][0])
    
    
    geo_dist_CHN = geo_dist.collect do | m |
        prov_raw, city_raw = m[0].split(":")
        ["#{province_city_name(prov_raw.to_i, city_raw.to_i)}", m[1] ]
    end
    
    sorted_provices_bi_count_CHN = sorted_provices_bi_count.collect {|m| [ province_name(m[0].to_i) , m[1] ] }
    
    puts "For weibo user #{poi_user.name}  total: Bi-lateral friends #{friends.total_items}"
    puts "RECORD: #{province_city_name( poi_user.province, poi_user.city)}  "
    puts "Bilateral friends count by city: #{geo_dist_CHN}"  # geo_dist
    puts "Bilateral friends count by province: #{sorted_provices_bi_count_CHN}"  # sorted_provices_bi_count
    puts "------------------------"
    puts "CALCULATED: if user location is among his/her bilateral frineds'"
    puts "inSameCity(or same area, for direct gov cities) ... #{inSameCity}"
    puts "inSameProvince  ... #{inSameProvince}"
    he_or_she = poi_user.gender == 'm'? 'He ': 'She '
    his_or_her = poi_user.gender == 'm'? 'his ': 'her '
    puts "A: So ... #{he_or_she} is #{(inSameCity || inSameProvince) ? '': 'not '} among #{his_or_her} bilateral friends ."
    puts "------------------------"
    puts "Gender distribution"
    
    #puts gender_dist.inspect
    #puts gender_dist.values.inspect
    sum = gender_dist.values.inject{|sum,x| sum + x }
    puts "Total #{sum}  people with gender. Actuall there are #{friends.total_items} people!"
    gender_dist.each_pair do | k, v|
        puts "#{k}, #{v}  ratio: #{'%.2f' % (v.to_f / sum.to_f)}"
    end
    #IDEA: if we can draw a map to highlight those dots, it will be clear gender difference among provinces.
    puts "------------------------"

    return [gender_dist, geo_dist_CHN, sorted_provices_bi_count_CHN]
end



if __FILE__ == $0
    # ------------------------------------------
    # IDEA: each requirement should be able to mapped to an array of attributes ( also help to increase the probability of accuracy), e.g. the 
    
    # find_bifriends_geo_distribution
    user = $client.user_show_by_screen_name "锅锅大仙"
    gender_dist, geo_dist_CHN, sorted_provices_bi_count_CHN = find_bifriends_geo_distribution(user.id)

=begin    
    # Create a pie chart
    puts "--------------- by Gender :"
    GoogleChart::PieChart.new('650x350', "Gender", false ) do |pc|
        
        gender_dist.each do |gender ,count|
            pc.data gender =="m"? "男": "女", count
        end
        
        puts pc.to_url
        
    end

    puts "--------------- by Province :"
    # Create a pie chart
    GoogleChart::PieChart.new('650x350', "Province", false ) do |pc|
        
        geo_dist_CHN.each do |loc,count|
            pc.data loc, count
        end
        
        puts pc.to_url
        
    end
    
    puts "--------------- by city :"
    # Create a pie chart
    GoogleChart::PieChart.new('650x350', "City", false ) do |pc|
        
        sorted_provices_bi_count_CHN.each do |loc,count|
            pc.data loc, count
        end
        
        puts pc.to_url
        
    end
=end    
end
