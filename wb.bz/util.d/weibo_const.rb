# ------------------------# ------------------------# ------------------------
require 'open-uri'
require 'httparty'

response = HTTParty.get('http://api.t.sina.com.cn/provinces.json')
#puts response.body, response.code, response.message, response.headers.inspect
a = JSON.parse(response.body)

# store cities into arrays
$provinces = a["provinces"]
#puts $provinces.inspect

def province_name(province_id)
    province_name = ""
    city_name = ""
    
    province_hashes = $provinces.select { |c| c["id"] == province_id }  # only one
    #puts province_hashes
    if province_hashes.size == 1
        province = province_hashes[0]
        province_name = province["name"]
    else
        # still return the id_code,
        province_name = province_id.to_s
    end

    return province_name
end

def province_city_name(province_id, city_id)
    province_name = ""
    city_name = ""
    
    province_hashes = $provinces.select { |c| c["id"] == province_id }  # only one
    #puts province_hashes
    if province_hashes.size == 1
        province = province_hashes[0]   # TODO: see if we can cache  this data!!!
        province_name = province["name"]
        
        # see:http://blog.hyfather.com/merging-an-array-of-hashes-in-ruby
        city_hashes =  Hash[*province["citys"].map(&:to_a).flatten]             
        #puts city_hashes.inspect
        city_name = city_hashes["#{city_id}"] || city_id.to_s
    else
        # still return the id_code,
        province_name = province_id.to_s
    end
    return "#{province_name}-#{city_name}"
end
