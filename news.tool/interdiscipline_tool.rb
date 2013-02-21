#encoding:UTF-8


#Purpose:2013.2.21
# * inspired by the rss feed, http://feedproxy.google.com/~r/NiemanJournalismLab/~3/Qr3MDAB7tgE/
# * to be well informed for new disciplines, in this case the news/journalism, news/report on this discipline always follows rule of 5w1h, tagging on that will help in filtering 
# * can also be timelined, find patterns or scheduling 

#Q: 2013.2.21 how to morph class into using different model base classes such as Active Record or 3rd party model? It will be useful to  
# hint: module inclusion like mongoid?  

require 'feedzirra'
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
    
    phrase_template = "([the|a]\s[A-Z].*?[[template]])" 
    phrases = $CONFERENCE_WORDS.map{|a|phrase_template.clone.gsub("[[template]]", a) }
    str = phrases.join("|")
    r = /\s(\w+Conf)\B|\s(\w+\-Con)\B|#{str}/im # assuming there are no special chars
    result = text.scan(r).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
    
    if serious
      single_word_check = /#{$CONFERENCE_WORDS.join('|')}/im
      result_for_check = text.scan(single_word_check).flatten.delete_if{|a|a.nil?}.map{|a|a.downcase}.uniq
      if result.size != result_for_check.size
        puts "[WARNING] Conference alike words spotted, but not parsed out correctly, please check the text"
        puts "-------------------------------------------------------"
        puts " #{text}"
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
  
  
  
  # NOTE: rss is much cleaner than web page content grabbed!
  def self.util_spot_from_rss(rss_link)

    feed = Feedzirra::Feed.fetch_and_parse(rss_link)
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
 
  nieman_rss = "http://www.niemanlab.org/feed/" # "http://feeds.feedburner.com/NiemanJournalismLab"; #  http://www.google.com/reader/view/feed/http%3A%2F%2Fwww.niemanlab.org%2Ffeed%2F
  confs = Conference.util_spot_from_rss(nieman_rss)
  
end



