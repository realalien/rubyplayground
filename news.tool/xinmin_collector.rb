#encoding: UTF-8
# --------------------- grab the content on target

# NOTE: Because content of news online is not universally in one format, let me get the xinmin daily first


require 'date'
require 'nokogiri'
require 'json'

require File.join(File.dirname(__FILE__),"./util.rb")

# TODO: web related exception handling.
class XinminDailyCollector

  def self.daily_news_links(date)
    pages_and_articles = []
    pages = self.find_pages_links(date)
  
    pages.each do |p|
      pages_and_articles << { 'page_title' => p['page_title'],
                              :page_link => p[:page_link],
                              'articles_links' => self.find_articles_links(p[:page_link]) }
    end
  
    return { :date_of_news =>  date.strftime("%Y-%m-%d"), 'pages_links' => pages_and_articles }
  end


  # invar:  date, a date on which the newspaper is available
  # outvar: hash, a link-to-page_title mapping (Note: as directory of one day's pages are the same, link only include node_xxx.htm info)
  # e.g. http://xmwb.xinmin.cn/html/2012-10/28/node_1.htm 
  #   is a page-listing webpage which contains
  #   * links to the articles on that page of newspaper whose links looks like 
  #  http://xmwb.xinmin.cn/html/2012-10/28/content_1_2.htm
  #   * links to other pages
  #  http://xmwb.xinmin.cn/html/2012-10/28/node_3.htm
  def self.find_pages_links(date)
    links_to_titles = []
    pages_dir = "http://xmwb.xinmin.cn/html/#{date.year}-#{date.strftime('%m')}/#{date.strftime('%d')}"
    
    first_page = "#{pages_dir}/node_1.htm" # ends with node_1.html
    page = WebPageTool.retrieve_content first_page #Nokogiri::HTML(open(first_page))
    
    
    if page
      page.parser.xpath("//table[@id='bmdhTable']//a[@id='pageLink']").each do |node|
        links_to_titles <<  {  :page_link => "#{pages_dir}/#{node['href']}"  , 'page_title' => node.content.gsub("\r\n", "") }
      end
    end

    #puts links_to_titles
    return links_to_titles
  end


  # invar:  page, a one entry of link-to-page_title mapping
  # outvar: hash, a link-to-page_title mapping
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

    return links_articles_to_titles
  end



  # invar date is supposed to be like '2012-10-26'
  def self.download_for_date(date=DateTime.now)

    # check if date is before today's afternoon, newspaper is supposed to be published, otherwise not available
    today = DateTime.now
    avail_hour = 17
    avail_time = DateTime.new(today.year, today.hour, today.min, avail_hour) # Q: how to deal with users of different timezone?

    if DateTime.parse(date) < avail_time
      self.grab_news_for_date(avail_time)
    end
  end

  def self.grab_news_for_date(datetiem)
  
  end

end



if  __FILE__ == $0
  
=begin
  # -------------------------    page and article grabbing    -------------------------
  #pages_links = XinminDailyCollector.find_pages_links(DateTime.new(2012,10,28))

  #page1 = pages_links.keys[0]
  #puts page1

  #articles_links = XinminDailyCollector.find_articles_links page1
  #puts articles_links

  puts  XinminDailyCollector.daily_news_links(DateTime.new(2012,11,20))

=end    


=begin
  # ------------------------- test of guess_content_of_page  -------------------------
  #link = "http://blog.twitter.com/2012/11/search-for-new-perspective.html"
  #page = WebPageTool.retrieve_content link
  
  
  # -----
  #f = File.open("twitter_blog.html") ; page = Nokogiri::HTML(f) ; f.close
  
  #link = "http://xmwb.xinmin.cn/html/2012-11/20/content_10_1.htm" ; page = WebPageTool.retrieve_content link
  #puts guess_content_of_page page
=end  
  
    
=begin
  # -------------------------  for fun: collect address infos from one-day newspaper ------------------------- 
    
  all_cnt = 0
  poi_cnt = 0
  page_cnt = 0
  poi = []
  articles_links = []
  links_json = XinminDailyCollector.daily_news_links(DateTime.new(2012,12,17))
  # -- make array of hash with title link
  links_json['pages_links'].each do |page|
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
  puts " #{poi_cnt} of #{all_cnt} can potential geo-tagged"
  
  File.open("news.txt", "w") do |f |
    poi.each do | h |
        f.puts h[:aritcle_title]
        f.puts h['article_link']
        f.puts h[:addresses]
        f.puts "---------------------------"
    end
  end

=end



=begin
  # -------- for fun: find weibo of those writers whose articles published in the pages named "夜光杯"

    
require File.join(File.dirname(__FILE__),"./wb.bz/util.d/weibo_client.rb")   
    
 links_json = XinminDailyCollector.daily_news_links(DateTime.new(2012,12,16))
 links_json['pages_links'].each do |page|
     
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
 end
=end

=begin
 
 # -------  command based xinmin article reader, not true, just listing
 # TODO: navigation between pages,  select article by number
=end
    
    links_json = XinminDailyCollector.daily_news_links(DateTime.new(2013,1,16))
    puts links_json
    puts "-------------------------------"
    useful = links_json['pages_links'].collect{|page|  page if page['page_title'] =~ /要闻/ }
    puts useful
    puts "-------------------------------"
    useful.each do |page|
        puts page 
        puts "----------  #{page['page_title']}  ---------"
    
        page['articles_links'].each do |art|
            puts "#{art['article_title']} : #{art['article_link']}"
            
            #raw = WebPageTool.retrieve_content(art['article_link'])
            #art[:text] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
            #puts art[:text]
            #puts "-------------------------------"
        end
    
    end
    
end



