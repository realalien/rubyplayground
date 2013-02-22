#encoding:UTF-8


#Purpose:2013.2.21
# * inspired by the rss feed, http://feedproxy.google.com/~r/NiemanJournalismLab/~3/Qr3MDAB7tgE/
# * to be well informed for new disciplines, in this case the news/journalism, news/report on this discipline always follows rule of 5w1h, tagging on that will help in filtering 
# * can also be timelined, find patterns or scheduling 

#Q: 2013.2.21 how to morph class into using different model base classes such as Active Record or 3rd party model? It will be useful to  
# hint: module inclusion like mongoid?  
require 'pp'
require 'feedzirra'
require 'date'
require 'yaml'
require File.join(File.dirname(__FILE__),"web_page_tools.rb")

class Event
  attr_accessor :start_date, :end_date
  attr_accessor :locations
  
end


class Conference < Event
  
  $CONFERENCE_WORDS = ["conference","symposium","seminar","roundtable"].map{|a| [a, a.capitalize]}.flatten
  # find it  # SUG: try to refactor code to 'spot_from_text'
  # TODO:  only English now!
  def self.spot_from_entry(entry, serious=true) #  , &blk block to allow to additional 
    #content = WebPageTool.retrieve_content(link).content
    

    $MAX_LENGTH_FOR_NAME = 30
    text = entry.content
    # r = /(the.{,30}?conference)|\s(\w+Conf)|\s(\w+\-Con)|(the.{,30}?symposium)|(the.{,30}?seminar)|(the.{,30}?roundtable)/im # assuming there are no special chars
    
    phrase_template = "(([A-Z][\\w\]*\\s)+[[template]])" 
    phrases = $CONFERENCE_WORDS.map{|a|phrase_template.clone.gsub("[[template]]", a) }
    str = phrases.join("|")
    r = /#{str}|\A(\w+Conf)\b|\A(\w+\-Con)\b/m # assuming there are no special chars
    puts r
    result = text.scan(r).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
    puts result
    
    if serious
      r_may_need_human_check = /#{$CONFERENCE_WORDS.join('|')}/m
      result_for_check = text.scan(r_may_need_human_check).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
      if result.size != result_for_check.size
        puts "[WARNING] Conference alike words spotted, but not parsed out correctly, please check the text from link below"
        puts "#{entry.url}"
        puts "-----Conference alike words found (#{result.size})-----"
        puts "#{result.join(', ')}"  if result.size > 0
        puts "-----Potential words not find out correctly!(#{result_for_check.size})-----" 
        puts "#{result_for_check.join(', ')}"
      end
    end
    
    result
  end
  
  def self.spot_from_text(text, serious=true) #  , &blk block to allow to additional 
    #content = WebPageTool.retrieve_content(link).content
    
    # TODO:  only English now!
    $MAX_LENGTH_FOR_NAME = 30
    #r = /(the.*?conference)|\s(\w+Conf)|\s(\w+\-Con)/
    
    phrase_template = "(([A-Z][\\w\]*\\s)+[[template]])"
    phrases = $CONFERENCE_WORDS.map{|a|phrase_template.clone.gsub("[[template]]", a) }
    str = phrases.join("|")
    r = /#{str}|\A(\w+Conf)\B|\A(\w+\-Con)\B|#{str}/im # assuming there are no special chars
    result = text.scan(r).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
    
    if serious
      single_word_check = /#{$CONFERENCE_WORDS.join('|')}/im
      result_for_check = text.scan(single_word_check).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
      if result.size != result_for_check.size
        puts "[WARNING] Conference alike words spotted, but not parsed out correctly, please check the text"
        puts "-------------------------------------------------------"
        # puts " #{text}"
        puts "-----Conference alike words found (#{result.size})-----"
        puts "#{result.join(', ')}"  if result.size > 0
        puts "-----Potential words not find out correctly!(#{result_for_check.size})-----" 
        puts "#{result_for_check.join(', ')}"
      end
    end
    
    result
  end
  
  # write down it
  def remember
  
  end
  
  # track it
  
  # build entity circles(relationship) around it
  
  
  
  # NOTE: 2013.2.22 since the rss feed is constantly unavailable(either redirect or connect reset), I still use page grabbing!
  # NOTE: because some blogs may have archive pages to hold blog links, from there it is easier to know what's new!
  def self.util_get_articles(num=10)
    month = Date.today.month
    year = Date.today.year

    article_link_by_year_month_partial = "http://www.niemanlab.org/%d/%02d/"
    
    archive_link_by_year_month_paginated_first = "http://www.niemanlab.org/%d/%d/"
    archive_link_by_year_month_paginated_nonfirst = "http://www.niemanlab.org/%d/%d/page/%d/"
    archive_link_by_year_month_paginated_partial = "http://www.niemanlab.org/%d/%d/page/%d/"
    
    page_num = 1
    count = 0
    all_article_links = []
    page_to_process = archive_link_by_year_month_paginated_first % [year,month] # might change by pagination
    
    while count < num do
      # find all article links
      page = WebPageTool.retrieve_content(page_to_process)
      
      if page
        article_links = []
        paging_links = %W{#{archive_link_by_year_month_paginated_first % [year,month]}, #{archive_link_by_year_month_paginated_nonfirst %  [year,month,page_num]}}
        
        page.links_with(:href => %r{^#{article_link_by_year_month_partial %  [year,month]}}i ).each do |p|
          article_links  << p.href unless paging_links.include?(p.href) # to remove pagination links
        end
 
        article_links = article_links.uniq.first(num)  # avoid too much articles link in one archive page!
        #pp article_links
        all_article_links << article_links
 
        # loop criteria update
        count += article_links.size
        
        # prepare for pagination
        page_num += 1
        
        if page_num != 1
          page_to_process = archive_link_by_year_month_paginated_nonfirst % [year,month, page_num]
        end
      else  # prepare for processing previous month
        month -= 1
        if month == 0
          month = 12 ; year -= 1
        end
        page_num = 1
        page_to_process = archive_link_by_year_month_paginated_first % [year,month]
      end
     
    end
    puts all_article_links
    all_article_links.flatten!
    puts all_article_links
    puts "------------------"
    # grab the page and save to an array of hash
    all_links_contents = []
    all_article_links.each_with_index do | link, idx |
      puts "Crawling .... #{link} at index : #{idx}"
      break if idx >= num 
      all_links_contents << {"link" => link, "content" => WebPageTool.retrieve_content(link).content }
    end
    pp all_links_contents
    all_links_contents
  end
  
  # NOTE: rss is much cleaner than web page content grabbed!
  def self.util_spot_from_rss(rss_link)

    feed = Feedzirra::Feed.fetch_and_parse(rss_link, {:user_agent => "Mac Safari"})
    if feed.is_a? Feedzirra::Parser::RSS
      puts feed.entries.size
      feed.entries.first(5).each_with_index do |entry, idx|
        puts "#{idx}    --------------"
        #puts "#{entry.content.sanitze!}"
        confs = self.spot_from_entry(entry)
        #puts confs
        if confs.size > 0
          puts "~~   #{entry.title}   ~~"  #.sanitize
          puts "Spot conference(s): #{confs.join(',')}" 
          puts "----------------------"
        end
      end
    else
      puts "Feed got appears to be #{feed}"
      puts "Can't get the feeds from #{rss_link}!"
      []
    end
  end
end



if __FILE__ == $0
  # Idea: given a link marked/tagged with 'journalism'(discipline) or 'rss'(format), it should be able to regulary check for new information to process once initiated! 
 
  # ------ test get data and parse from rss feeds
  #nieman_rss = "http://www.niemanlab.org/feed/" # "http://feeds.feedburner.com/NiemanJournalismLab"; #  http://www.google.com/reader/view/feed/http%3A%2F%2Fwww.niemanlab.org%2Ffeed%2F
  #confs = Conference.util_spot_from_rss(nieman_rss)
  
  
  # ------ test get data from page crawling
  

  temp_file = "first5.yaml"
  
  if not File.exists?(File.join(File.dirname(__FILE__), temp_file))
      first5 = Conference.util_get_articles(5)
      File.open( temp_file, 'w' ) do |out|
        YAML.dump( first5 , out )
      end
  end
  
  articles = File.open( temp_file ) { |yf| YAML::load( yf ) }
  
  
  articles.each do | article|
    puts "For link : #{article['link']}" 
    confs = Conference.spot_from_text(article['content'])
    puts "Found: ....#{confs.join(',')}" if confs.size > 0
  end
 
  
  
end



