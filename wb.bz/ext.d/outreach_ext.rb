#encoding:UTF-8

require File.join(File.dirname(__FILE__),"demo.rb")

=begin    
    # ------------------------------------------
    # TODO: from the source of the status, we can find other services integrated with weibo, if that source has a web site with communities, we can link different account of the same use.
    # AFM: one piece of info can be treated as a layer of access point, from which more knowledge can be gained.

 
    # >>>>>>>>>> find out all status's source app. group them all.
    # TODO: it's a waste to regularly pull the data from server, see if we can create a plugable service make following test functions.
    user = $client.user_show_by_screen_name("realalien")
    #user = $client.user_show 1961488257

    sts = $client.statuses(user.id)
    
    sources = {}
    i = 0
    while sts.next_page? #Loops untill end of collection
        sts.each do | s |
            #puts s.inspect
            link = Nokogiri::XML s.source
            elem = link.xpath("//a[@href]")
            elem2 = link.xpath("//a/@href")
            #puts link
            puts elem.first.text    #"<name of app>"
            puts elem2.first.text   #"http://xxxx.xxx.com/ssss"
            
            uri = URI(elem2.first.text).host
            #puts elem.first
            #puts link.class
            sources[elem.first.text] = uri unless sources.keys.include? elem.first.text
            
            #i += 1
            #if i > 5 then
            #    break 
            #end
        end
    end 
    puts sources.inspect
=end
 
    
    # from user: realalien
    d = {"FaWave"=>"chrome.google.com", "新浪微博"=>"weibo.com", "土豆网推视频"=>"login.tudou.com", "分享按钮"=>"open.weibo.com", "iPhone客户端"=>"m.weibo.com", "iPad客户端"=>"m.weibo.com", "又拍网"=>"www.yupoo.com", "优酷网连接分享"=>"www.youku.com", "未通过审核应用"=>nil, "豆瓣FM"=>"douban.fm", "豆瓣读书"=>"book.douban.com", "加网分享按钮"=>"www.jiathis.com", "微博搜索"=>"s.weibo.com", "CNTV"=>"www.cntv.cn", "mifan米饭网"=>"mifan.me", "凤凰网"=>"www.ifeng.com", "投票"=>"vote.weibo.com", "新浪博客"=>"blog.sina.com.cn", "CSDN新闻分享"=>"news.csdn.net", "微活动"=>"event.weibo.com", "爱问共享资料"=>"ishare.iask.sina.com.cn", "56网连接分享"=>"www.56.com"}
    

    # >>>>>>>>>> search user with the name with common query interface 
    user_name = "realalien"
    yupoo_q_user = "http://www.yupoo.com/search/people/?q=#{user_name}"
    
    


