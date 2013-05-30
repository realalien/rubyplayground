#encoding:UTF-8




class XinMinDailyAnalyst
  
  
  #self.geo_find_address
  
  # 2013.3.13 extract or l
  
end


def find_page_title_without_seq(full_title)
  if match = full_title.match(/第[A-Z][0-9]+版：(.*)/i)
    puts match.captures.class
    short_title = match.captures
    short_title.first
  else
    ""
  end
end

module PageIndexIntelligence
  
  # A,B sections, A section contains news, B miscellaneous 
  def is_normal_page
    
  end
  
  # detect the page title that never seen before  
  def is_known_page_title
    
  end
      

end

# working on titles of the 'page index'
module Research_PageIndex_Title
  
  
  def assumed__pages_on_news
    ['新闻','要闻']
  end


  # SUG: better if we can sematically parsed the title, but do it later
  def assumed__pages_none_of_geo_importance
    ['财经新闻', '文娱新闻','体育新闻','国际新闻']
  end
  
 
  def is_news_of_geo_importance(title)
    return title.match(/#{assumed__pages_on_news.join('|')}/) && (not title.match(/#{assumed__pages_none_of_geo_importance.join('|')}/))
  end
  
end


module Research_Filtering
  
  # usually pointing to the article on other page,'>>>详见Axx版'
  def is_article_of_redirect_placeholder(content)
    return content.match(/>>>详见[A-Z].*版/) 
  end
  
  def is_of_ads(title)
    return title.match(/广告|报头/)
  end
  
end



module Scrutinization
  
  include Research_PageIndex_Title
  include Research_Filtering
  
  def util_listing_china_city_mentioned(yr,m,d)
     # of one day
    XinminDailyCollector.delete_daily_news_from_db(yr,m,d)
    ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr,m,d)) 
    
    puts ps.size 
    puts "--------"
    if ps.size <= 0
      XinminDailyCollector.save_daily_news_to_db(yr,m,d,force_reload_articles=true, get_content=true )
      ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr,m,d)) 
    end
    
    # of point of interest
    pois = ps.select{|e| is_news_of_geo_importance(e.page_title) }
    puts pois.map(&:page_title).join("  ")
    # for each page, parse the geo from article and do statistics
    pois.each do |page|
      next if is_of_ads(page.page_title) # filtering
      puts "------------------ #{page.page_title} -------------------"
      all_articles = 0
      articles_has_geo_info = 0
      page.articles.each do |article|
        next if is_article_of_redirect_placeholder(article.content) || is_of_ads(article.article_title) # fitering
        all_articles += 1.0 # count total
        
        r = scan_chinese_province_or_municipality(article.content, "上海")
        if r && r.size > 0
          provinces_grouped = r.flatten.group_by{|c|c}.map{|k,v| [k, v.length]}.sort{|c|c[1]}
          puts "[INFO] #{article.article_title} ---->  #{provinces_grouped}   #{article.article_link}"  # .join(',')
          
          articles_has_geo_info += 1
          provinces_grouped.each do | prov |
              puts "scanning sub district ...#{scan_chinese_city_or_district_by_province(article.content, prov[0] )}"
          end 
        else
          puts "[INFO] #{article.article_title} ---->  no provincial name found.   #{article.article_link}"
        end
    
      end
      if all_articles > 0
        puts "[STAT] #{articles_has_geo_info} of #{all_articles} (#{articles_has_geo_info/all_articles}) ... geo locatable!"
      else 
        puts "[STAT] No article processed!"
      end
      puts ""
      
    end
  end
  
  def simple_page_retrieve_test
    # ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(2013,5,3))

    #ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(2013,5,3)) 
    # Useful ctriteria for querying
    #  .where({:page_title.nin => assumed_pages_none_of_geo_importance}) 
    #  .where("page_title".in => /要闻|新闻/ )
    #puts ps.size
    #puts ps.map(&:page_title).join("  ")
    # 第A01版：一版要闻  第A02版：要闻  第A07版：综合新闻  第A09版：民生新闻  第A11版：法治新闻  第A14版：中国新闻  第A15版：国际新闻  第A18版：文娱新闻  
    # 第A20版：体育新闻  第A08版：科教卫新闻  第A10版：社会新闻  第A13版：中国新闻  第A16版：国际新闻  第A17版：文娱新闻  第A19版：文娱新闻  第A21版：体育新闻  
    # 第A22版：体育新闻  第A23版：财经新闻
    
    #puts find_page_title_without_seq("第A04版：评论·随笔")
  end
  
end


require File.join(File.dirname(__FILE__),"xinmin_collector.rb")

if __FILE__ == $0


=begin
  # ----- filter out some pages, and then parse geo info for the rest -----
  include Scrutinization
  util_listing_china_city_mentioned(2013, 5, 30)
=end


=begin
  # ----- test of hacking theme relation creation. 
=end
  one_page = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(2013,5,30)).with_seq_no(1)
  pp eg_article = one_page.first.articles.first

end


