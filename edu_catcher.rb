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
        return page
    end
end
    

class XinminDailyCollector
    
    
    def self.grab_newspaper_on_date(date)
        
        pages = self.find_pages_links(date)
        
        pages.each do |p|
            self.find_pages_links(p)
        end
        
    end

    # invar:  date, a date on which the newspaper is available
    # outvar: hash, a link-to-page_title mapping
    def self.find_pages_links(date)
        
    end

    # invar:  page, a one entry of link-to-page_title mapping
    # outvar: hash, a link-to-page_title mapping
    def self.find_articles_links(page)
        
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









# -------------------------------------------------------------
#
# -------------------------------------------------------------




if __FILE__ == $0
    s = "上海交通口腔医学院"
    puts s.has_edu_organization?
    
    s = "谈闵星说，不同年级的候选人的问题也不同。“比如，刚加入少先队的三年级候选人的问题是‘在中队里，你曾经有过怎样的服务岗位，你在这个岗位上怎么做的’；上海交大口腔医学院前身是震旦大学医学院牙医系，设在广慈医院，是国内最早设立的口腔医学院校之一。”"
    has_edu_organization?(s).each do |item|
       puts "-->#{item}"
    end
    
end
