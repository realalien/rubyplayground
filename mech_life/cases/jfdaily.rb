

# example , parse page http://www.jfdaily.com/a/1429845.htm "“十二五”将投140亿建教育工程"

# 'Ruby Cookbook' 14.1
require 'uri'
require 'net/http'

PAGE_REQUEST_INTERVAL = 3
 
def detect_new_article_links(*num_idx_pages)
      
end

# peek if there is an article for that static page => imply: 
def detect_new_article_link(link)
    response = Net::HTTP.get_response(URI.parse(link))
    puts "#{link}"
    puts "......response.code => #{response.code} "
    response
end






## ------------------------------------
## Peripheral Utilities
## ------------------------------------

def peek_jfdaily_articles_by_idx(start_index)
  return unless start_index.is_a? Fixnum
  
  jfdaily_article_link_format = "http://www.jfdaily.com/a/__index__.htm"
  
  not_ok_count = 0
  
  while not_ok_count < 3
    newlink = jfdaily_article_link_format.sub("__index__", start_index.to_s)
    response = detect_new_article_link(newlink)
    
    if not response.is_a? Net::HTTPOK
      not_ok_count += 1
    end
    
    start_index += 1
  end
end

if __FILE__ == $0
   1100.times {  detect_new_article_link('http://www.jfdaily.com/a/1430790.htm')   }
    #peek_jfdaily_articles_by_idx(1429845)
end