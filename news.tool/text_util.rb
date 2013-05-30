#encoding:UTF-8


require 'json'
# --------------------------------------------------------------
# Simple way of processing target info, not using NLP processing
# --------------------------------------------------------------


def find_text( expects_arr , raw)
    r = Regexp.new(expects_arr.join("|"))
    return raw.scan(r)
end

# facade of processing address text in an news article, processes including ...
# * tokenize by sentence
# 
def find_addr_in_article( article)
    ss = article.split(%r{；|，|、|。”|　|。})  # Chinese sentence period.
    
    potential_address = []
    ss.each do |s|
        s.strip!
        addr = find_chinese_addr_by_levels(s)

        if addr && addr.size > 0
            addr[0].strip!
            potential_address << [:addr => addr[0], :context => s] 
        end
    end
    
    return potential_address
    
end    


# TODO: simple impl., assuming only one address appeared, can't handle two addresses yet.
# TODO: may need NLP because text before the road name is mistakenly treated as part of the road name.
def find_chinese_addr_by_levels(str)
    levels = ["省","市","岛",
              "区","县","湾","村",
              "路","街","巷","小区","弄","里",
              "号","號","室"]
    
    # the loop is designed to do that ...
    # once a character in "levels" is found, try to find more detailed address with later charcters in "levels"(can bypass missing levels).
    
    regx_valid = ""
    regx_test = ""
    used_level = 0  # assuming addr is useless if only has one level
    while (addr_level = levels.shift) != nil
        # assuming in the context of address, some levels requires numbers!
        if addr_level =~ /号|號|室/
            if regx_valid == ""  # assuming address can't be valid with only these '[号|號|室]' info
                return nil
            else 
                regx_test = regx_valid + "\\d+#{addr_level}"  ; # puts  "regx_test     [ #{regx_test} ]"
            end
        else 
            regx_test = regx_valid + "\\S+#{addr_level}"  ; # puts  "regx_test     [ #{regx_test} ]"
        end
        
        
        if str.scan(Regexp.new(regx_test)).size > 0
            regx_valid = regx_test
            used_level += 1
        else
            next
        end
        
    end
    
    if regx_valid.size > 0 and used_level > 1
        # puts regx_valid; puts str; puts "---------------"
        return str.scan(Regexp.new(regx_valid))
    else
        return nil
    end

end

# ---------------

def load_json_from_filecache(filename)
  if File.exists? filename
    JSON.parse( IO.read(filename) )
  else 
    nil
  end
  

end

def save_json_to_file_cache(filename,jsonData)
  File.open("./#{filename}","w") do |f|
    f.write(jsonData)
  end
end

#module FactsFromInternet
#end

require File.join(File.dirname(__FILE__),"web_page_tools.rb")

def china_admin_division_by_weibo_api_v2_provinces_json
  filename = "#{__method__.to_s}.json"
  saved = load_json_from_filecache(filename)
  unless saved
    saved = JsonTool.jsonGet('http://api.t.sina.com.cn/provinces.json')
    save_json_to_file_cache(filename, saved.to_json)
  end
  saved
end  


def provinces_names_via_weibo_api_v2_provinces_json
    # first iteration to scan provincial name
  known = china_admin_division_by_weibo_api_v2_provinces_json
  
  provinces = known["provinces"]
  unwanted = ['其他', '海外']
  prov_names = provinces.collect{ |c| c["name"] }
  prov_names.delete_if{|c| unwanted.include?(c)}
  prov_names
end



def scan_chinese_province_or_municipality(str, default_prov="")
  prov_names = provinces_names_via_weibo_api_v2_provinces_json
  #puts prov_names
  r = Regexp.new(prov_names.join("|"))
  result = str.scan(r)
  
  if result && result.size > 0 
    result
  elsif default_prov && default_prov.length > 0  # allow the context of location awareness
    return [default_prov]
  else
    nil  
  end

end



def scan_chinese_city_or_district_by_province(str, province)
  # clean out "市" ( if 'Municipality' 直辖市) for searching Weibo info 
  province_cleaned = province.gsub('市', '')
  
  # get cities/districts by province
  known = china_admin_division_by_weibo_api_v2_provinces_json
   
  provinces = known["provinces"]
  
  for prov in provinces do
    if prov['name'] == province_cleaned
      cities = prov['citys'].collect{|e|e.values}.flatten.map do |e| 
        if e =~ /浦东新区/ 
          e 
        else 
          e.gsub('区','')
        end
      end
      r = Regexp.new(cities.join("|"))
      #puts r
      result = str.scan(r)
      if result && result.size > 0
        return [ province, result.flatten.group_by{|c|c}.map{|k,v| [k, v.length]}.sort{|c|c[1]} ]
      else
        break  # find the province, but no sub district found.
      end
    end  
  end
  
  return [ province, [] ]   # emtpy city 
end





if __FILE__ == $0
  
  # -------
  #find_chinese_addr_by_known_names(nil)
  
  
  # base class test out
=begin    
    content = WebPageTool.retrieve_content "http://xmwb.xinmin.cn/html/2012-11/20/content_8_5.htm" # "张江地区现异味气体"
    xpath = "//div[@id='ozoom']"
    puts WebPageTool.locate_text_by_xpath( xpath , content)
    puts "-----"


    
    
    #test_dir = "./tests/"
    #Test::Unit::AutoRunner.run(true, test_dir)
    
    
    # ATTENTION, for simplicity of regex, use longer text before shorter ones.
    text = "毕节市七星关区环东路人行道1118号"
    
    #"5名死亡男性少年　　陶中井(12岁)，陶中红(11岁)，陶冲(12岁)，陶波(9岁)，陶中林(13岁)　　本报讯  毕节消息：贵州省毕节市委宣传部今日零时10分许向媒体提供一份书面名单，披露4天前死于该市市区垃圾箱中的5名男性少年身份系当地三名同胞兄弟之子。　　据此可以认定，这五名少年，既有兄弟关系，也有堂兄弟关系。　　一氧化碳中毒5少年“闷死”　　今年11月16日早晨，毕节市七星关区一名捡拾街头垃圾老妇发现有5名男性少年死于街头一个铁质可封闭垃圾箱内。事发路段位于毕节市七星关区环东路人行道，距离流仓桥街道办事处步行约需1分钟。"
    
    
    
    #r = find_text(["社区","街道","路"], text)
    r = find_chinese_addr_by_levels(text)
    puts r
    puts r.size
    
=end
    
end
