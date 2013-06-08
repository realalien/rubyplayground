#encoding:UTF-8


require 'uri'

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
    ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr,m,d)) 
    puts ps.size 
    puts "--------"
    if ps.size <= 0
      XinminDailyCollector.save_daily_news_to_db(yr,m,d,force_reload_articles=true, get_content=true, verbose=true)
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
=end

  #XinminDailyCollector.delete_daily_news_from_db(2013, 6, 7)
  #include Scrutinization
  #util_listing_china_city_mentioned(2013, 6, 7)


  # # --------------------  query-based (no search engine) data analysis playground ---------
  # # parpare
  #XinminDailyCollector.save_news_to_db_by_range("2013-5-1","2013-5-31")
  #puts "All done!"

=begin
  
=end   
  # # search for titles
  
  def util_articles_title_on_keyword(keywords)
    # clean keywords with
    kws = []
    if keywords.is_a? String
      kws << keywords.gsub('|','')
    elsif keywords.is_a? Array
      kws = keywords.map{ |e| e.gsub('|','')}
    end
    
    pois = XinMinDailyArticlesModelForCollector.includes(:pageIndex)
                                              .where("article_title" => /#{kws.join('|')}/ )
                                              .and("pageIndex.page_title" => /新闻/)
                                              .asc("date_of_news") 
    
    if pois.count > 0
      pois.each do | article |
        puts "#{article.infos.map(&:reporters).flatten} #{article.article_title.strip} \t\t\t ( #{article.pageIndex.page_title} )"
      end
    else
      pp "No data found!"
    end
  end
  
  #util_articles_title_on_keyword('市长')  # ['A股','股市']  ['任命','当选']  '市长'  '死'


    
  def add_info_reporters(article)
    reporters = XinminDailyCollector.find_the_authors(URI.unescape(article.raw_content))
    if reporters.size > 0 and article.infos.map(&:reporters).size <= 0 #has parsed data and no existing
      # pp "adding reporters ...... article: #{article.article_title}  reporters: #{reporters}"
      d = DistilledData.new
      d[:reporters] = reporters
      article.infos << d
      article.save
    end
  end





=begin
  # # find all parsed info in embedded document
  pages = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(2013,5,30)).with_seq_no(1)
  eg_article = pages.first.articles.first
  pp eg_article.infos.map(&:reporters)
  

  # # test of adding parsed data
  reporters = XinminDailyCollector.find_the_authors(URI.unescape(eg_article.raw_content))
  d = DistilledData.new
  d[:reporters] = reporters
  eg_article.infos << d
  eg_article.save 


  # # test of query for existing data
  pp XinMinDailyArticlesModelForCollector.where( "infos.reporters" => { "$exists" => true  } ).size 
  pp XinMinDailyArticlesModelForCollector.where( "infos.reporters" => { "$exists" => false } ).size


  # # test of add parsed data 
  no_rpts = XinMinDailyArticlesModelForCollector.where( "infos.reporters" => { "$exists" => false } )
  pp "[Info] Started..."
  no_rpts.each_with_index do |article, idx|
    add_info_reporters(article)
    idx += 1
    pp "[Info] #{idx}/#{no_rpts.size} processed."
  end


  # # test of query all articles for reporters
  all_rpts = XinMinDailyArticlesModelForCollector.where( "infos.reporters" => { "$exists" => true } )
  all_rpts.each do |article|
    puts "#{article.article_title} ...... #{article.infos.map(&:reporters)}"
  end
 
  
  
  # # test of query for specific reporter
  arts = XinMinDailyArticlesModelForCollector.any_in( "infos.reporters" => ['陶邢莹', '连建明'] )
  arts.each do |article|
    puts "#{article.article_title} ...... #{article.infos.map(&:reporters).flatten}"
  end     
 


  
  # # test of seeking authors in the pages of interest
  news_titles = ['财经新闻']
  pages = XinMinDailyPageIndexModelForCollector.any_in("page_title" => /#{news_titles.join('|')}/i )
  pois = pages.map{|p|p.articles}.flatten
  pois.each do |article|
    puts "#{article.article_title}(#{article.article_link}) ...... #{article.infos.map(&:reporters).flatten}"
  end 
  
  # IDEA: if we put two timelines(authors's twits and entity dev. seq.) together, what insights might be got?
  
  
  # Q: is the news relayed or first-written?
  # 结构性行情持续演绎(http://xmwb.xinmin.cn/html/2013-05/30/content_26_3.htm) ...... ["连建明"]
  # 两公司被证监会调查(http://xmwb.xinmin.cn/html/2013-05/30/content_26_4.htm) ...... ["连建明"]
  
  require File.join(File.dirname(__FILE__),"../wb.bz/util.d/weibo_client.rb")   
  
  # # Deviation, find colleagues of '陶邢莹' via Weibo engine, for what? org study? staff geo analysis?
  # TODO: create a pool for studying group of people, use existing info to pin down the most likely account
  
  # bi-friends scan and with 'xinmin' in the description
  #target_user = $client.user_of_screen_name('Peach爱吃桃子')  # '陶邢莹'
  #friends = $client.bilateral_friends(target_user.id) # TODO: should save friends temp
  
  #fs = []
  #friends.each do |f|
  #  fs << f
  #end
  
  #File.open( './tao_bifriends.yaml', 'w' ) do |out|
  #  YAML.dump( fs , out )
  #end
        
  local_read = File.open( './tao_bifriends.yaml' ) { |yf| YAML::load( yf ) }
  
  pois = local_read # local_read.select{|e| e.verified_reason =~ /新民晚报/}
  if pois.size > 0
     pois.each do |e|
      pp "#{e.screen_name}(loc: #{e.location}id: #{e.id}，org_role: #{e.verified_reason}) ... #{e.description} " if e != nil
     end
  else 
     pp "no person of interest found!"
  end

=end 
 
  
  # # test of apply parsing process on a group of data, ie. articles
  
  
  
  
  
  # # find a group of articles, by date, and then by month or by year, later by select range
  # # by date
  def articles_by_date(yr,m,d)
    XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr,m,d)).collect{|page|page.articles}.flatten
  end
  # # by date and pages
  def articles_by_date_page(yr,m,d,page_nos)
    pages = []
    unless page_nos.is_a? Array
      pages << page_nos
    else 
      pages = page_nos
    end
    
    articles = []
    pages.each do | page_no |
      articles << XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(yr,m,d)).with_seq_no(page_no).collect{|page|page.articles}.flatten
    end
    
    articles.flatten
  end



def prep_authors_data
  
end

  #pp articles_by_date_page(2013,5,30, 1).collect{|a|a.article_title}
  #pp articles_by_date_page(2013,5,30, [0,1]).collect{|a|a.article_title}
  


=begin
  # # --- just scanning some articles without saving crawled text into local database.
  
   
=end



end


