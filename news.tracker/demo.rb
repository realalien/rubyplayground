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




# Note: here we assume that a string is a well formatted full sentence, ending with a period
#       so it will be easier to parse for the money numbers, ratios and other useful numbers.
class String
    
    # Find out any number, whether it is a fraction or an integer, no matter if it is a pertage or a number value
    def has_number?
        if self.scan(/[+-]?(?:(?!0)\d+|0)(?:\.\d+)?/).size > 0  # regex, REF. http://rubular.com/r/OFBdEv0VeP
            return true
        else
            return false
        end
    end
    
    
    # NOTE: should we convert all chinese numbers to numeric number?
    def has_date?
        # note: (((\d+|今)年)*(\d+(月份|月))(\d+日)*    # month is only required
        # note: ((\d+|今)年)   # only year is presented
        if self.scan(/(\d+年|今年|去年|明年)*(\d+月份|\d+月)(\d+日|上旬|中旬|下旬)*|(\d+年|今年|去年|明年)|日前|目前|年初|年底|年末|月初|月末|前一周|本周|下周/).size > 0
           return true
        else
           return false
       end
    end
    

    def date_record
        # note: (((\d+|今)年)*(\d+(月份|月))(\d+日)*    # month is only required
        # note: ((\d+|今)年)   # only year is presented
        r = self.scan(/(\d+年|今年|去年|明年)*(\d+月份|\d+月)(\d+日|上旬|中旬|下旬)*|(\d+年|今年|去年|明年)|日前|目前|年初|年底|年末|月初|月末|前一周|本周|下周/)
		#puts r.inspect
		# TODO: for the moment, the date elements are scattered among match groups, we need to collect them all
		if r.size > 0
		    date_mentions = []	
			r.each do | e |
				if e.is_a? Array
					date_mentions << e.compact.join("")
				elsif e.is_a? String
					date_mentions << e
				else
					# we don't accept, Q: could regex has deeper grouping?
				end
			end
			return date_mentions.flatten.join(",")
        else
           return ""
       end
    end

    # this can help to filter a lot of numbers which stands for months/number-counts/...
    def has_large_money_numbers?
        if self.scan(/(?:(?!0)\d+|0)(?:\.\d+)?(多)*(亿|千万|百万|十万|万)/).size > 0  # units usually mainly appeared in printable newspaper. Q:how to put array in a regex?  A:
            return true 
        else
            return false
        end
    end
    
    
    # array of numbers(with units)
    def large_money_numbers
        return self.scan(/(?:(?!0)\d+|0)(?:\.\d+)?(多)*(亿|千万|百万|十万|万)/)
    end
    
    
    # Find the percentage ratio
    
    def has_ratio_numbers?
        # fraction number with digit is like (?:(?!0)\d+|0)(?:\.\d+)?
        if self.scan(/((?:(?!0)\d+|0)(?:\.\d+)?%|(?:(?!0)\d+|0)(?:\.\d+)?:(?:(?!0)\d+|0)(?:\.\d+)?)/).size > 0  # units usually mainly appeared in printable newspaper. Q:how to put array in a regex?  A:
            return true 
        else
            return false
        end
    end
    
    # Check if the ration number is roughly calculated.
    def is_ratio_numbers_rough?
        if self.scan(/(近|将近|大约|约)(?:(?!0)\d+|0)(?:\.\d+)?%/).size > 0  # units usually mainly appeared in printable newspaper. Q:how to put array in a regex?  A:
            return true 
        else
            return false
        end
    end
    
    # Find out if it's a month-to-month or year-to-year growth
    def growth_type
        a = self.scan(/(同比|环比)/)  # NOTE:TODO: non-formal hacking. it may not correct
       if a.size > 0
           return a[0]
       else
           return ""
       end
    end
    
    # Guess what industry the number is related to.
    # TODO: industry based on the sentence may not be correct, should use article context.
    def industry
        # ref. http://www.360doc.com/content/11/0319/04/2739067_102464261.shtml
        a = self.scan(/铁路运输|钢铁|港口运输|煤炭|电力能源|农林牧渔|机械|科技|有色金属|中小板|建筑|医药|酒店旅游|农药化肥|食品加工|通信|造酒|电力设备|电子信息|商业百货|家电|航天|石油化工|房地产|金融|证券|保险/)  # NOTE:TODO: non-formal hacking.
        if a.size > 0
            return a[0]
        else
            return ""
        end
        
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
    s = "11亿，这是今年1-4月份全国70余家大中型钢铁企业利润总额，环比增长20%。256亿，这是这些钢厂同期的贷款利率、“贷款顾问费”、水利建设基金等各种财务费用总额，财务费用同比上涨将近40%"
    # s: note:  acutally, this piece of info is finance related, the expenditure is about different sub industries.
    
    # NOTE: because some detailed data is not obvious to all, we can only piece together the discreet data, so, please don't try to build a model from bottom up, it may be impossible.
    
    # HAHA: we can seperate the sentence by periods, each sentence can be archived with a lot of meta data, once the data is enough for analysis, we can hack into it( search and aggregate). We can also use other authentic news agents.
    
    # TODO: retrieve several month's data from eeo(or others if data is not sufficient enough) to parse the data for an industry.
    
=begin      
    items = s.split("。")
    puts items
    items.each do | sentence |
        puts sentence.industry.inspect
    end
=end 
	

	# link = "http://www.eeo.com.cn/2012/0622/228773.shtml"
	#link = "http://www.eeo.com.cn/2012/0627/228943.shtml"  
    #link = "http://www.eeo.com.cn/2012/0312/222544.shtml"
	link = "http://www.eeo.com.cn/2012/0630/229200.shtml"


    page = retrieve_content(link)
    title, content = eeo_title_and_content(page)
    
    all_numbers = []
    full_qualified = []
    date_with_ratio = []
    only_date = []

	recoverable = []   # contains the original sentences    
    recovered = []     # contains the original sentences with date appended.

    items = content.split("。")
	items = items.collect { |e| e.strip; e.gsub(/\s+/, "") }
    #puts items
    items.each do | sentence |
        sentence = sentence.strip
        if  sentence.has_number?
            all_numbers << sentence
        end
        
        if sentence.has_date? && sentence.has_large_money_numbers?
           full_qualified << sentence 
        end
        
        if sentence.has_date? && sentence.has_ratio_numbers? && !sentence.has_large_money_numbers?  
            date_with_ratio << sentence
        end
        
        if sentence.has_date? && !sentence.has_ratio_numbers? && !sentence.has_large_money_numbers? 
            only_date << sentence
        end
    end
    
    # Infer date from previous sentence
	excepts = (all_numbers - full_qualified - date_with_ratio - only_date)
    excepts.each do | e|
	  #if e.include? "力帆汽车销售有限公司(以下简称“力帆汽车销售”)为解决在公"
		e_idx = items.find_index e
		#puts "e_idx  --->  #{e_idx}"
		#puts "e_idx.class --->  #{e_idx.class}"
		search_idx = 0	
		# search previous sentences until it find a date
		search_idx = e_idx - 1 unless e_idx.nil?
		while search_idx >= 0  
			prev = items[search_idx]
			#puts "search: #{search_idx}, prev  ---->  #{prev}"
			date = prev.date_record		
			if !date.nil? && !date.empty?
				modified = e + "[上文提到时间:#{date}]"
				#puts "Find date:  modified  ----> #{modified}"	
				if e.has_large_money_numbers?
					recovered << modified
					recoverable << e
					# stop search
				end
				break
			end
			search_idx -= 1
		end
      #end
	end

    
    #puts "---------   all sentence with number: #{all_numbers.size} --------"
    #all_numbers.each do |s|
    #   puts "---> #{s}"  
    #end

	puts "---------   all sentence full_qualified: #{full_qualified.size} --------"
    full_qualified.each do |s|
        puts "---> #{s}"  
		puts "    date mentioned: #{s.date_record}"
    end
    
    puts "---------   all sentence date_with_ratio only: #{date_with_ratio.size} --------"
    date_with_ratio.each do |s|
        puts "---> #{s}"  
		puts "    date mentioned: #{s.date_record}"
    end
    
    puts "---------   all sentence date only: #{only_date.size} --------"
    only_date.each do |s|
        puts "---> #{s}"  
		puts "    date mentioned: #{s.date_record}"
    end
	
    puts "---------   all sentence recovable #{recoverable.size} --------"
    recoverable.each_with_index do |s, idx|
        puts "---> #{s}"  
		puts "     #{recovered[idx]}"
    end


    puts "---------------------------------------------------------------- exceptional: "
    a = (all_numbers - full_qualified - date_with_ratio - only_date - recoverable)
	if a.size == 0
		puts "Thanks God! There is none!"
	else
		a.each do |s|
        	puts "---> #{s}"  
		end
    end

    # TODO: some missing info might be mentioned in difference sentences of the same paragraph, if number related info is missing, try to deduce from the context.
    
    # NOTE: after parsing some data, it looks like some data is intentionally used for camouflage for naive readers! To find evidences of evil writer, we can check if the writer is devoted to some kind of topic or some conflict of interests.
    
    
    # TODO: there are much more combination of chinese number in sentence, make a comparison tool to collect the sentences those are filtered out, make the judgement knowledge materialized.
    
    
    
    #IDEA: the information is just one piece of information, imagine we pull an article using some kind of rope,
    #     at first we may not know what it(result) will be, by elaborating the metaphor, the class type of the obj
    #     should be created depending on if we need to persist it, how much the similarity among the information, the usage!
    #   It's a tempertation to 
    
    #IDEA: the purpose here is to prove that the money is spent unwisely on the major companies.
    
    
    
end





