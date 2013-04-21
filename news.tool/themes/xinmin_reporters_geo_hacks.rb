#encoding: UTF-8

# Origin impetus
# http://xmwb.xinmin.cn/html/2013-04/20/content_4_4.htm
# The perspective is partial and didn't disclose much info. about himself and his community.
# Personal gain and lose is not well specified!


# Abstract
# * find the geo locations(DATA) of reporter/writers(PERSON) who write on 'commentary' column(DATA, cut)
#   by sns and other probable information online (PROCESS)
#   in order to get the sense where the opinions are generated from.(PURPOSE)




# Start up process
#  collect news (DONE in supporting class)
#  -> parse out authors  
#  ->  use multiple strategies to find location(e.g. SNS )
#  -> aggregate

require File.join(File.dirname(__FILE__),"../xinmin_models.rb")
require File.join(File.dirname(__FILE__),"../xinmin_collector.rb")

# weibo
require File.join(File.dirname(__FILE__),"../../wb.bz/util.d/weibo_client.rb")


def automate_test
  theme = HackingTheme.new
  theme.theme_name = "authors_geo_analysis_since_2013_4_21"
end


def one_article_parse_test
  author_name =  XinminDailyCollector.find_the_author("http://xmwb.xinmin.cn/html/2013-04/20/content_4_4.htm")
  puts author_name
  # stategy one 1  - weibo candidates
  candidates_ids = $client.search_suggestions_users()
  puts candidates_ids.class
  
  candidates_ids.each do | e |
    puts e.uid
    puts $client.user(e.uid).inspect
  end

end

# --------------------------------------------------------------------------------
# Proof of concepts
# * find the target (from weibo person search )

# --------------------------------------------------------------------------------

if  __FILE__ == $0
  one_article_parse_test
end
