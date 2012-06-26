#encoding:UTF-8
require 'mongoid'
require 'mechanize' 
require File.join(File.dirname(__FILE__), "models.rb") 

# --- General Ideas ---
# STEP: find new articles.
# STEP: extract the news from source and save
# STEP: extract keywords,  experimenting the news knowledge extracting design model
# NOTE: make all process as automatical as possible, human intervention is for studying use.
# NOTE: applying learning methods such as 'three books theory' to the news study
# Q: why not based on a CMS system?

# -----------------  setup

Mongoid.configure do |config|
    name = "news_tracker_dev"
    host = "localhost"
    port = 27017
    config.database = Mongo::Connection.new.db(name)
end


# -----------------
# STEP: extract the news from source and save

$a = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
}

#TODO: there are much useful data(e.g. link meta data, probably for SEO, so).
def retrieve_content(url)
    begin
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        page = m.get(url) 
    rescue => e 
        puts "[Error] retrieving #{url} "
        puts e.message
        puts e.backtrace
        # $ACCUMULATED_DELAY += 1
        puts "[WARNING] Compulsory put programming into sleep due to page retrieval error. Back to work in #{$ACCUMULATED_DELAY} minute(s)"
        # sleep $ACCUMULATED_DELAY
        
        # just return an empty Mechanize::Page
        page =  Mechanize::Page.new
    ensure
        #$TOTAL_PAGE_REQUEST += 1
        
        #puts page.inspect
        
        #puts page.content
        return page
    end
end


# process after retrieving the raw page, return raw title and raw content(with html tag)
# Q: how to deal with article that of regular updates?
# A: 
# TODO:  unforseeable page element id change handling
def eeo_title_and_content(page)
    xpath = "//div[@id='text_content']"
    node_set = page.search(xpath)
    
    if node_set and node_set.length > 0 
        #puts node_set[0].inner_text
        return [page.title, node_set[0].inner_text]
    else
        return [nil,nil]
    end
end




def find_all_sentences_with_number
    
end



class String
    
    # units usually mainly appeared in printable newspaper.
    CHN_LARGE_NUMBER_UNITS_SHORT = ["亿","千万","百万","十万","万"];
    
    def has_numbers
        return true if self =~ /\d+/
        return false    
    end
    
    # this can help to filter a lot of numbers which stands for months/number-counts/...
    def has_large_money_numbers
       
    end
    
    
    # array of numbers(with units)
    def money_numbers
        
        
    end    
end

if __FILE__ == $0
    
    # extract
    #page = retrieve_content("http://www.eeo.com.cn/2012/0622/228773.shtml")
    #title, content = eeo_title_and_content(page)
    
    
    
    
    # auto highlight parsed data
    
    
    
    
    # extract number
    
    

    # sentence data extract exp.
    # NOTE: if not parsable by machine, we should create tools for collect info and help to analysis the number
    s = "11亿，这是今年1-4月份全国70余家大中型钢铁企业利润总额。256亿，这是这些钢厂同期的贷款利率、“贷款顾问费”、水利建设基金等各种财务费用总额，财务费用同比上涨将近40%"
    # NOTE: because some detailed data is not obvious to all, we can only piece together the discreet data, so, please don't try to build a model from bottom up, it may be impossible.
    
    # HAHA: we can seperate the sentence by periods, each sentence can be archived with a lot of meta data, once the data is enough for analysis, we can hack into it( search and aggregate). We can also use other authentic news agents.
    
    # TODO: retrieve several month's data from eeo(or others if data is not sufficient enough) to parse the data for an industry.
    
    
    items = s.split("。")
    puts items
    items.each do | sentence |
        
    end 
    
    
    #IDEA: the purpose here is to prove that the money is spent unwisely on the major companies.
    
    
    
end





