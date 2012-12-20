#encoding:UTF-8

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
        addr = find_chinese_addr(s)

        if addr && addr.size > 0
            addr[0].strip!
            potential_address << [:addr => addr[0], :context => s] 
        end
    end
    
    return potential_address
    
end    


# TODO: simple impl., assuming only one address appeared, can't handle two addresses yet.
# TODO: may need NLP because text before the road name is mistakenly treated as part of the road name.
def find_chinese_addr(str)
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



if __FILE__ == $0
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
    r = find_chinese_addr(text)
    puts r
    puts r.size
    
=end
    
end
