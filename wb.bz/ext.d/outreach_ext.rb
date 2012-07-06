#encoding:UTF-8

require File.join(File.dirname(__FILE__),"../util.d/scraper.rb")
require File.join(File.dirname(__FILE__),"../util.d/weibo_client.rb")

require File.join(File.dirname(__FILE__),"../ext.d/friends_ext.rb")
=begin    
    # ------------------------------------------
    # TODO: from the source of the status, we can find other services integrated with weibo, if that source has a web site with communities, we can link different account of the same use.
    # AFM: one piece of info can be treated as a layer of access point, from which more knowledge can be gained.

 
    # >>>>>>>>>> find out all status's source app. group them all.
    # TODO: it's a waste to regularly pull the data from server, see if we can create a plugable service make following test functions.
=end 



def find_3rd_party_apps(weibo_screen_name)
    user = $client.user_show_by_screen_name(weibo_screen_name) ;#user = $client.user_show 1961488257
    sts = $client.statuses(user.id)
    
    sources = {}
    i = 0
    while sts.next_page? #Loops untill end of collection
        sts.each do | s |
            link = Nokogiri::XML s.source
            xpath = "//a[@href]"
            elem = link.search(xpath)  # ; puts elem.first.text  ; puts elem.first['href']
            
            uri = URI(elem.first['href']).host
            sources[elem.first.text] = uri unless sources.keys.include? elem.first.text
            
            # IDEA: it doesn't looks smart to iterative through all the statuses to find out all 3rd party links. Better solution?
            
            # Debug use: limited search
            #i += 1
            #if i > 5 then
            #    break 
            #end
        end
    end 
    # puts sources.inspect
    return sources
end 
    

    # outreach communities of the user: realalien, e.g. 
    #d = {"FaWave"=>"chrome.google.com", "新浪微博"=>"weibo.com", "土豆网推视频"=>"login.tudou.com", "分享按钮"=>"open.weibo.com", "iPhone客户端"=>"m.weibo.com", "iPad客户端"=>"m.weibo.com", "又拍网"=>"www.yupoo.com", "优酷网连接分享"=>"www.youku.com", "未通过审核应用"=>nil, "豆瓣FM"=>"douban.fm", "豆瓣读书"=>"book.douban.com", "加网分享按钮"=>"www.jiathis.com", "微博搜索"=>"s.weibo.com", "CNTV"=>"www.cntv.cn", "mifan米饭网"=>"mifan.me", "凤凰网"=>"www.ifeng.com", "投票"=>"vote.weibo.com", "新浪博客"=>"blog.sina.com.cn", "CSDN新闻分享"=>"news.csdn.net", "微活动"=>"event.weibo.com", "爱问共享资料"=>"ishare.iask.sina.com.cn", "56网连接分享"=>"www.56.com"}


# NOTE: 
# * weibo_name is not randomly assigned plain text, this method is supposed to be used in the scenario that 'weibo user.statuses[i].source is from "又拍网"(www.yupoo.com)'
def search_yupoo_corresponding_accounts(weibo_screen_name)
    # >>>>>>>>>> search user with the name with common query interface 
    user_name =  weibo_screen_name  #"realalien"
    yupoo_q_user = "http://www.yupoo.com/search/people/?q=#{user_name}"
    
    potential_accounts = {}
    page = retrieve_content(yupoo_q_user)
    xpath = "//div[@class='search-people-list']/ul[@class='people-list']"
    node_set = page.search(xpath)

    if node_set.children.size > 0  # which means there are a group of <li> 
        all_li = node_set.css "li"
        puts "[INFO] total #{all_li.size} potential accounts might be related."
        all_li.each do |li|
            sub_xpath = "//h3[@class='top']/a[@href]"
           
            name = li.search(sub_xpath).text.strip
            link_node = li.search(sub_xpath).first
            #puts name ; #puts link['href']
            potential_accounts[name] = link_node['href']
        end
    else
        puts "[INFO] no result for query '#{user_name}'"
    end

    # IDEA: we may use 'face recognition' programs to find persons, and matching with weibo's hypothesis about age, gender, check-ins.
    #potential_accounts.each_pair do |k,v|
    #   puts "#{k} ......  #{v}" 
    #end
    
    return potential_accounts
end


name = "Bobby_Wang" # "牙牙妈" # "Flyerlemon"
puts "[LOGGING] search_yupoo_corresponding_accounts ... #{name}"
pts = search_yupoo_corresponding_accounts(name)
puts "-----------------------------------"
puts "potential accounts: #{pts}"
puts ""


=begin
  
# ATTENTION: User requests out of rate limit!  
#user = $client.user_show_by_screen_name("realalien")
user = $client.user_show "1191241142"
friends = $client.bilateral_friends(user.id)

puts "Yupoo accounts ..............."
friends.each do | f|
    puts "[LOGGING] find_3rd_party_apps for user ... #{f.screen_name}"
    s = find_3rd_party_apps(f.screen_name)
    if s.has_key?("又拍网")
        puts "[LOGGING] search_yupoo_corresponding_accounts ... #{f.screen_name}"
        pts = search_yupoo_corresponding_accounts(f.screen_name)
        
        puts "-----------------------------------"
        puts "#{f.name}"
        puts "potential accounts: #{pts}"
    end
end
=end


