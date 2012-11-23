#encoding:UTF-8


# Purpose: find the organizations info from edu news and put it into an human life cycle management time-table, later can be extended to medical info/news analysis


# IDEA: 2012.10.25, 
# * considering that casual scripting with temporary data is not of much use in analytics, data storage(portable) should be established.
# * Also, the data and the scripts are always under heavy changes, I think of creating a layer of data persistence, an experimental environment to check the quality of scripts, if pass the usage/worthwhile acceptance, then make it into a data center like storage!

  


$AVG_HUMAN_LIFE_EXPAND = 110

# Q: how to introduce locale (like apple's API) into the data retrieving?
# A:
# TODO: should read write to include new data!
$EDU_LEVEL_TIMETABLE = {
    "小学" => (7..11),
    "初中" => (12..14),
    "高中" => (15..17),
    "本科" => (18..22),
    "研究生" => (22..24),  # regular as planned, not accurate
    "博士" => (22..26),
    "博士后" => (26..28)
}


# TODO: should read write to include new data!
$EDU_ORG = ["小学", "中学", "大学", "研究院"]



# -------------------------------------------------------------
# find the article with EDU_LEVEL info, also quote the sentence
# -------------------------------------------------------------



# --------------------- grab the content on target

# NOTE: Because content of news online is not universally in one format, let me get the xinmin daily first







require 'nokogiri'
require 'mechanize'

class WebPageTool
    def self.retrieve_content(url)
        begin
            m = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
            page = m.get(url)
        rescue => e 
            puts "[Error] retrieving #{url} "; puts e.message; puts e.backtrace
            page = nil
        ensure
        #puts page.inspect ; #puts page.content
        end
        return page
    end


    def self.locate_text_by_xpath( xpath , content)
        doc = nil
        if  content.is_a? String
            doc = Nokogiri::HTML(content)
        elsif content.is_a? Mechanize::Page
            doc = Nokogiri::HTML(content.content)
        end
    
        # TODO: supposed to find only one, refine and warning if more than one 
        node = doc.at_xpath(xpath)
        node.content
    end
end
    




require 'date'
require 'nokogiri'
require 'json'

# TODO: web related exception handling.
class XinminDailyCollector

    
    def self.grab_newspaper_on_date(date)
        

    end

    def self.daily_news_links(date)
        pages_and_articles = []
        pages = self.find_pages_links(date)
        
        pages.each do |p|

            pages_and_articles << { :page_title => p[:page_title],
                                    :page_link => p[:page_link],
                                    :articles_links => self.find_articles_links(p[:page_link]) }
            
        end
        
        return { :date_of_news =>  date.strftime("%Y-%m-%d"), :pages_links => pages_and_articles }
    end


    # invar:  date, a date on which the newspaper is available
    # outvar: hash, a link-to-page_title mapping (Note: as directory of one day's pages are the same, link only include node_xxx.htm info)
    # e.g. http://xmwb.xinmin.cn/html/2012-10/28/node_1.htm 
    #   is a page-listing webpage which contains
    #   * links to the articles on that page of newspaper whose links looks like 
    #      http://xmwb.xinmin.cn/html/2012-10/28/content_1_2.htm
    #   * links to other pages
    #      http://xmwb.xinmin.cn/html/2012-10/28/node_3.htm
    def self.find_pages_links(date)
        links_to_titles = []
        pages_dir = "http://xmwb.xinmin.cn/html/#{date.year}-#{date.strftime('%m')}/#{date.strftime('%d')}"
    
        first_page = "#{pages_dir}/node_1.htm" # ends with node_1.html
        page = WebPageTool.retrieve_content first_page #Nokogiri::HTML(open(first_page))
        
        page.parser.xpath("//table[@id='bmdhTable']//a[@id='pageLink']").each do |node|
            links_to_titles <<  {  :page_link => "#{pages_dir}/#{node['href']}"  , :page_title => node.content.gsub("\r\n", "") }
        end

        #puts links_to_titles
        return links_to_titles
    end


    # invar:  page, a one entry of link-to-page_title mapping
    # outvar: hash, a link-to-page_title mapping
    def self.find_articles_links(page_link)
        links_articles_to_titles = []

        page = WebPageTool.retrieve_content page_link

        page.parser.xpath("//div[@id='btdh']//a").each do |node|
            # puts node['href'] ; puts node.content;
            links_articles_to_titles << { :article_link => "#{File.dirname(page_link)}/#{node['href']}" , 
                                         :aritcle_title => node.content.gsub("\r\n", " ") }
        end

        return links_articles_to_titles
    end



    # invar date is supposed to be like '2012-10-26'
    def self.download_for_date(date=DateTime.now)

        # check if date is before today's afternoon, newspaper is supposed to be published, otherwise not available
        today = DateTime.now
        avail_hour = 17
        avail_time = DateTime.new(today.year, today.hour, today.min, avail_hour) # Q: how to deal with users of different timezone?

        if DateTime.parse(date) < avail_time
            self.grab_news_for_date(avail_time)
        end
    end

    def self.grab_news_for_date(datetiem)
        
    end

end




# ---------------------  parse sentence
class String
    # Q: how can I apply the functions to specific objects rather than alll the string objects
    def has_edu_organization?
        r = Regexp.new($EDU_ORG.join("|"))
        if self.scan(r).size > 0
            return true
        else
            return false
        end
    end
    
    def edu_organizations
        r = Regexp.new($EDU_ORG.join("|"))
        return self.scan(r)
    end
    
end

# ---------------------  find sentences with target info

def has_edu_organization?(str)
    mentions = []  # array of hash
    
    # TODO: how to look forward to include
    ss = str.split(%r{；|。”|。})  # Chinese sentence period.

    ss.each do |s|
        if s.has_edu_organization?
            orgs = s.edu_organizations
            mentions << { orgs => s }
        end
    end
    
    mentions.each do |item|
        puts "#{item.keys[0]} -->   #{item[item.keys[0]]}"
    end
end




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




# -------------------------------------------------------------
# Given a well-intended webpage(e.g. ), find the div tag with most content.
# assuming it has the most useful content for analysis, cut the job of xpath search

# NOTE: target English websites
# -------------------------------------------------------------

# http://stackoverflow.com/questions/2465032/how-can-unwanted-tags-be-removed-from-html-using-nokogiri
module Filter
    def remove_tags!(*list)  # _preserve_content
        xpath('.//*').each do |element|
            if list.include?(element.name)
                element.children.reverse.each do |child|
                    # child_clone = child.clone
                    # element.add_next_sibling child_clone
                    child.unlink
                end
                element.unlink
            end
        end
    end
    
    def remove_non_p_tags!  # _preserve_content
        xpath('.//*').each do |element|
            if "p" != (element.name) 
                element.children.reverse.each do |child|
                    # child_clone = child.clone
                    # element.add_next_sibling child_clone
                    child.unlink
                end
                element.unlink
            end
        end
    end
    
end

class Nokogiri::XML::Element
    include Filter
end

class Nokogiri::XML::NodeSet
    include Filter
end


require 'sanitize'

def choose_by_p_tag_under_div(doc)
    nodes = doc.xpath "//div[not(*[descendant::div]) ]"
    
    clean_divs = nodes.map{|e| e.remove_non_p_tags!  ;  e }  # e.remove_non_p_tags! ; puts "#{e} ------";
                      .map(&:content)
                      .sort{ |a,b| a.length <=> b.length}.reverse
    
    if clean_divs.size > 0
         #puts clean_divs.at(0);  #puts "Total : #{clean_divs.size}"
        clean_divs.at(0)
    else
        nil
    end
end

def choose_by_sanitize_text_under_div(doc)
    nodes = doc.xpath "//div[not(*[descendant::div]) ]"
    
    puts nodes
    clean_divs = nodes.map(&:content)
    .map{|e| Sanitize.clean(e) ; e.gsub!(/\s+/, "") ; e  }  # puts "#{e.class}..#{e.length}....." ;
                      .sort{ |a,b| a.length <=> b.length}.reverse
    
    if clean_divs.size > 0
        # puts clean_divs.at(0); puts "<<<<<<<"
        clean_divs.at(0)
    else
        nil
    end
end

def guess_content_of_page(content)
    doc = nil
    if  content.is_a? String
        doc = Nokogiri::HTML(content)
    elsif content.is_a? Mechanize::Page
        doc = Nokogiri::HTML(content.content)
    elsif content.is_a? Nokogiri::HTML::Document
        doc = content
    end
    
    
    # TODO: still unsafe, need human intervention! IDEA: compare with page title content!(safe-enough?)
    if doc
        r = choose_by_p_tag_under_div(doc.clone)
        
        if !r || r.gsub(/\s+/,"") == ""
            puts ">>>>>>>> select by choose_by_sanitize_text_under_div"
            r = choose_by_sanitize_text_under_div(doc.clone) ;            
            r
        else 
            puts ">>>>>>>> select by choose_by_p_tag_under_div"
            r 
        end
    end
end



# -------------------------------------------------------------
#
# -------------------------------------------------------------





if __FILE__ == $0
    
=begin
    s = "上海交通口腔医学院"
    puts s.has_edu_organization?
    
    s = "谈闵星说，不同年级的候选人的问题也不同。“比如，刚加入少先队的三年级候选人的问题是‘在中队里，你曾经有过怎样的服务岗位，你在这个岗位上怎么做的’；上海交大口腔医学院前身是震旦大学医学院牙医系，设在广慈医院，是国内最早设立的口腔医学院校之一。”"
    has_edu_organization?(s).each do |item|
       puts "-->#{item}"
    end

=end 
    
    
    
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
    
    
    
=begin
    # -----  page and article grabbing
    #pages_links = XinminDailyCollector.find_pages_links(DateTime.new(2012,10,28))
 
    #page1 = pages_links.keys[0]
    #puts page1
    
    #articles_links = XinminDailyCollector.find_articles_links page1
    #puts articles_links
    
    puts  XinminDailyCollector.daily_news_links(DateTime.new(2012,11,20))
 
 
=end    
    # ---- test of guess_content_of_page
    #link = "http://blog.twitter.com/2012/11/search-for-new-perspective.html"
    #page = WebPageTool.retrieve_content link
    
    
    # -----
    #f = File.open("twitter_blog.html") ; page = Nokogiri::HTML(f) ; f.close
    
    link = "http://xmwb.xinmin.cn/html/2012-11/20/content_10_1.htm" ; page = WebPageTool.retrieve_content link
    puts guess_content_of_page page
  

    
    
    # content grabbing and text processing
=begin
    
    
    all_cnt = 0
    poi_cnt = 0
    page_cnt = 0
    poi = []
    articles_links = []
    links_json = XinminDailyCollector.daily_news_links(DateTime.new(2012,11,21))
    # -- make array of hash with title link
    links_json[:pages_links].each do |page|
        page_cnt +=1
        break if page_cnt > 24
        page[:articles_links].each do |article|
            puts "[INFO] Processing #{article[:article_title]} from #{article[:article_link]}" ; all_cnt+=1;
            raw = WebPageTool.retrieve_content(article[:article_link])
            article[:text] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
            
            addrs = find_addr_in_article(article[:text])
            
            if addrs.size > 0
                article[:addresses] = addrs
                
                poi << article; poi_cnt += 1
            end
            #puts page[:text]
            #puts "----------------------"
        end
    end


    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts " #{poi_cnt} of #{all_cnt} can potential geo-tagged"
    
   File.open("news.txt", "w") do |f |
    poi.each do | h |
        f.puts h[:aritcle_title]
        f.puts h[:article_link]
        f.puts h[:addresses]
        f.puts "---------------------------"
    end
   end

=end
    
    
    
    
    
    
end
