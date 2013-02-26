#encoding:UTF-8
# --------------------- grab the content on target

# NOTE: Because content of news online is not universally in one format, let me get the xinmin daily first


require 'date'
require 'nokogiri'
require 'json'
require 'mongoid'
require 'yaml'

require File.join(File.dirname(__FILE__),"xinmin_models.rb")
require File.join(File.dirname(__FILE__),"web_page_tools.rb")

# http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
YAML::ENGINE.yamler = 'syck'

# Q: any better place for configuration  A:
MONGOID_CONFIG = File.join(File.dirname(__FILE__),"mongoid.yml") 
Mongoid.load!(MONGOID_CONFIG, :development)
Mongoid.logger = Logger.new($stdout)
# ------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------

class XinminDailyCollector

  def self.daily_news_toc_first_time(date)
    pages_and_articles = []
    pages = self.find_pages_links(date)
  
    pages.each do |p|
      pages_and_articles << { 'page_title' => p['page_title'],
                              :page_link => p[:page_link],
                              'articles_links' => self.find_articles_links(p[:page_link]) }
    end
  
    return { 'date_of_news' =>  date.strftime("%Y-%m-%d"), 'pages_links' => pages_and_articles }
  end

  def self.daily_news_toc_reload(yr,m,d)
    if yr.is_a? String || m.is_a? String || d.is_a? String
        yr,m,d = *[yr,m,d].map(&:to_i)
    end
    # always try to find toc from file to cut time short.
    tmp_file = File.join(File.dirname(__FILE__), "page_index_hash_#{yr.to_i}_#{m.to_i}_#{d.to_i}.yaml")

    unless File.exists? tmp_file
      toc = XinminDailyCollector.daily_news_toc_first_time(Date.new(yr,m,d))
      puts "toc retrieved...."
    
      File.open( tmp_file, 'w' ) do |out|
        YAML.dump( toc , out )
      end
    end

    toc = File.open( tmp_file ) { |yf| YAML::load( yf ) }
    # puts "toc: #{toc}"
    
    # Basic check for newspaper is still unavailable
    if toc['pages_links'] == []
      puts "[NOTICE] news for #{toc['date_of_news']} is not available, try later!"
    end
    
    toc
  end
 
  def self.save_daily_news_to_db(yr,m,d,force_reload_articles=false, get_content=false)
    toc = self.daily_news_toc_reload(yr,m,d)
    # TODO: check for validness of toc
    date_of_news = toc['date_of_news']
    pages_links = toc['pages_links']
    one_date = Date.strptime(date_of_news, fmt='%Y-%m-%d')

    pages_links.each_with_index do |page, idx|
      # get page index model
      pgidx_db = XinMinDailyPageIndexModelForCollector.on_specific_date(one_date).with_seq_no(idx).first
      
      if pgidx_db
        #puts "[INFO] Page Index ( date: #{date_of_news}, seq_no: #{idx}) has already been collected!"
        pgidx = pgidx_db
      else
        #puts "[INFO] Making new Page Index ( date: #{date_of_news}, seq_no: #{idx})"
        # build page index model
        pgidx = XinMinDailyPageIndexModelForCollector.new(JSON.parse(page.to_json))
        pgidx.date_of_news = one_date
        pgidx.seq_no = idx
        pgidx.articles ||= []
        
        pgidx.save!
      end
    
      if force_reload_articles
        puts "Deleting articles ... (page index: #{idx})"
        pgidx.articles.delete_all
      end  
      
      # build article models, 
      # * please be noticed that the actual content of article is not retrieved here!
      # * here it is assumed that articles will be cheeck for validateion
      page['articles_links'].each do |article|
        #puts "Converting ... #{article['article_title']} : #{article['article_link']}"
        article['date_of_news'] =  pgidx.date_of_news     # follow page index
      
        if get_content
          puts "Retriving content ....(#{article['article_title']},#{article['article_link']})"
          article['content']  = self.grab_news_content(article['article_link']) 
        end		 
 
        art = XinMinDailyArticlesModelForCollector.new(JSON.parse(article.to_json))
        art.pageIndex = pgidx
        art.save
        puts "Saving article done =============="
      end

      #pp pgidx
      #puts "--------- (page: #{idx}) ... collected!"
    end # of each page
  end


  # Notes:
  #  http://xmwb.xinmin.cn/html/2012-10/28/node_1.htm is a one-page articles listing web page which contains:
  #  links to the article pages whose url look like http://xmwb.xinmin.cn/html/2012-10/28/content_1_2.htm
  def self.find_pages_links(date)
    links_to_titles = []
    pages_dir = "http://xmwb.xinmin.cn/html/#{date.year}-#{date.strftime('%m')}/#{date.strftime('%d')}"
    
    first_page = "#{pages_dir}/node_1.htm"
    page = WebPageTool.retrieve_content first_page
    
    if page
      page.parser.xpath("//table[@id='bmdhTable']//a[@id='pageLink']").each do |node|
        links_to_titles <<  {  :page_link => "#{pages_dir}/#{node['href']}"  , 'page_title' => node.content.gsub("\r\n", "") }
      end
    end

    links_to_titles
  end


  def self.find_articles_links(page_link)
    links_articles_to_titles = []

    page = WebPageTool.retrieve_content page_link
    if page
      page.parser.xpath("//div[@id='btdh']//a").each do |node|
      # puts node['href'] ; puts node.content;
      links_articles_to_titles << { 
          'article_link' => "#{File.dirname(page_link)}/#{node['href']}" , 
          'article_title' => node.content.gsub("\r\n", " ") }
      end
    end

    links_articles_to_titles
  end
  

  def self.grab_news_content(article_link)
    raw = WebPageTool.retrieve_content(article_link)
    text = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
    text
  end
  
  
  # Note: 
  # * example code
  # * it looks necessary to create relationship between articles and 'page index', so that we can later retrieve a specific articles(see if downloaded or not and other info.)
  def self.util_listing_news_for_date(yr,m,d)
    toc = XinminDailyCollector.daily_news_toc_reload(yr,m,d)
    #useful = links_dict['pages_links'].collect{|page|  page if page['page_title'] =~ /要闻/ }
    #useful.each do |page|
    toc['pages_links'].each do |page|
    puts "----------  #{page['page_title']}  ---------"
    
      page['articles_links'].each do |article|
        #puts "Retrieving #{article['article_title']} : #{article['article_link']}"
        puts "#{article['article_title']} : #{article['article_link']}"
        
        #raw = WebPageTool.retrieve_content(article['article_link'])
        #article['text'] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
        #article['date_of_news'] = Date.strptime(toc['date_of_news'], fmt='%Y-%m-%d')
        #pp art ; puts "-------------------------------"
      end
    end
  end
  
  def self.util_listing_news_of_toc(toc)
    # pp toc
    # pp "%%%%%%%%%%%%"    
    toc['pages_links'].each do |page|
    puts "----------  #{page['page_title']}  ---------"
    
      page['articles_links'].each do |article|
        #puts "Retrieving #{article['article_title']} : #{article['article_link']}"
        puts "#{article['article_title']} : #{article['article_link']}"
        
        #raw = WebPageTool.retrieve_content(article['article_link'])
        #article['text'] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
        #article['date_of_news'] = Date.strptime(toc['date_of_news'], fmt='%Y-%m-%d')
        #pp art ; puts "-------------------------------"
      end
    end
  end
  
   # just retrieve partial pages those are of interest. 
  # _listing_ means process on cli, not on data from database
  # NOTE: texts in 'excluded' should use as less words as possible so not to kill too many pages!
  def self.util_listing_pages_of_interest(toc, excluded=[], included_if_excl=[])
    page_to_remove = []
    if excluded.size > 0
      toc['pages_links'].each do |page|
        r = /#{excluded.join("|")}/ # assuming there are no special chars
        if r === page['page_title']
          if included_if_excl.size > 0
            r_incl = /#{included_if_excl.join("|")}/
            if r_incl === page['page_title']
              # do not remove
            else
              
              page_to_remove << page
            end
          else # included_if_excl 
            page_to_remove << page
          end
        end
      end
      
      toc['pages_links'] -= page_to_remove
      return toc
    else # no exclusion
      return toc
    end
  end
  
  # -------------------------  for fun: collect address infos from one-day newspaper ------------------------- 
  def self.play_addresses_in_articles(yr,m,d)  
     require File.join(File.dirname(__FILE__),"./text_util.rb")
      puts "starting.."
    all_cnt = 0
    poi_cnt = 0
    page_cnt = 0
    poi = []
    articles_links = []
    links_dict = XinminDailyCollector.daily_news_toc_reload(yr,m,d)
    # -- make array of hash with title link
    links_dict['pages_links'].each do |page|
        page_cnt +=1
        break if page_cnt > 24
        page['articles_links'].each do |article|
            puts "[INFO] Processing #{article['article_title']} from #{article['article_link']}" ; all_cnt+=1;
            raw = WebPageTool.retrieve_content(article['article_link'])
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
    puts " #{poi_cnt} of #{all_cnt} can  be potentially geo-tagged"
    
    File.open("news.txt", "w") do |f |
      poi.each do | h |
          f.puts h[:aritcle_title]
          f.puts h['article_link']
          f.puts h[:addresses]
          f.puts "---------------------------"
      end
    end
  end

  # -------- for fun: find weibo of those writers whose articles published in the pages named "夜光杯"
  def self.play_guess_weibo_accounts_from_article_authors(yr,m,d)
    require File.join(File.dirname(__FILE__),"./wb.bz/util.d/weibo_client.rb")   
      
    links_dict = XinminDailyCollector.daily_news_toc_reload(yr,m,d)
    links_dict['pages_links'].each do |page|
       
      #puts page['page_title'].gsub(/\s/,"")
      if  page['page_title'] =~ /夜光杯/ 
        page['articles_links'].each do |article|
          puts "[INFO] Processing #{article['article_title']} from #{article['article_link']}" ;
          raw = WebPageTool.retrieve_content(article['article_link'])
          article[:text] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
       
          tokens =  article[:text].split("　").delete_if { |t | t.strip == "" }
       
         if tokens.size > 0
           author =  tokens[0].strip.gsub("　","").gsub("◆", "").gsub(" ", "").gsub(" ", "") 
           puts "Detecting weibo account for #{author}"
           begin 
             user = $client.user_show_by_screen_name(author).data
             puts "#{user['screen_name']}  #{user['id']} " 
           rescue 
             puts "#Couldn't find weibo info by screen_name #{author}"  
           end    
                
           sleep 2
          end
        end
      end
    end # of each do |page|
  end
  
  
=begin
  # invar date is supposed to be like '2012-10-26'
  def self.util_download_for_date(date=DateTime.now)

    # check if date is before today's afternoon, newspaper is supposed to be published, otherwise not available
    today = DateTime.now
    avail_hour = 17
    avail_time = DateTime.new(today.year, today.hour, today.min, avail_hour) # Q: how to deal with users of different timezone?

    if DateTime.parse(date) < avail_time
      self.grab_news_for_date(avail_time)
    end
  end

=end

end



if  __FILE__ == $0
  
  # -------------------------    page and article grabbing    -------------------------
  #pages_links = XinminDailyCollector.find_pages_links(DateTime.new(2012,10,28))
  #page1 = pages_links.keys[0]   ; #puts page1
  #articles_links = XinminDailyCollector.find_articles_links page1  ; #puts articles_links
  #puts  XinminDailyCollector.daily_news_toc_reload(2012,11,20)    


=begin
  # ------------------------- test of guess_content_of_page  -------------------------
  #link = "http://blog.twitter.com/2012/11/search-for-new-perspective.html"
  #page = WebPageTool.retrieve_content link
  
  #f = File.open("twitter_blog.html") ; page = Nokogiri::HTML(f) ; f.close
  
  #link = "http://xmwb.xinmin.cn/html/2012-11/20/content_10_1.htm" ; page = WebPageTool.retrieve_content link
  #puts guess_content_of_page page
=end  


=begin
  # ---------------------  test of 'download_news_for_date' methods
  puts "starting..."
  XinminDailyCollector.util_listing_news_for_date(2013,2,25)
  puts "Listing... DONE!"  
=end
  
  
=begin
 ---------------------  test of 'save_daily_news_to_db'
  XinminDailyCollector.save_daily_news_to_db(2013,2,19,force_reload_articles=true, get_content=true )
=end


=begin
 
 ---------------------  test of 'util_listing_pages_of_interest'


 XinminDailyCollector.util_listing_news_for_date(2013,2,20)
 toc = XinminDailyCollector.daily_news_toc_reload(2013,2,20)
 toc_of_interst = XinminDailyCollector.util_listing_pages_of_interest(toc,excluded=['第B','广告','夜光杯','文娱','体育','国际','人才','旅游','财经','连载','阅读'])
 pp toc
 XinminDailyCollector.util_listing_news_of_toc(toc_of_interst)
=end


=begin
---------------------  test of 'retrieving specific pages and its articles' 

puts "start..."
ps = XinMinDailyPageIndexModelForCollector.on_specific_date(DateTime.new(2013,2,4)).with_seq_no(3)

puts ps.length
puts ps.first.articles.size

ps.first.articles.each do | article |
  pp article
end
=end   

  
end



