#encoding:UTF-8
# --------------------- grab the content on target

# NOTE: Because content of news online is not universally in one format, let me get the xinmin daily first


require 'date'
require 'nokogiri'
require 'json'
require 'mongoid'
require 'yaml'

# http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
YAML::ENGINE.yamler = 'syck'


require File.join(File.dirname(__FILE__),"./util.rb")

# Q: any better place for configuration  A:
MONGOID_CONFIG = File.join(File.dirname(__FILE__),"mongoid.yml") 
Mongoid.load!(MONGOID_CONFIG, :development)
Mongoid.logger = Logger.new($stdout)
# ------------------------------------------------------------------------------------

# Note: this class is to make the json structure more explicit!
class XinMinDailyArticlesModelForCollector
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
  
  
  field :article_title, type: String
  field :article_link, type: String
  field :content, type: String
  field :date_of_news, type: Date
  
  belongs_to :pageIndex, class_name: "XinMinDailyPageIndexModelForCollector", inverse_of: :articles
  
  validates :article_link,  :uniqueness => {:scope => :date_of_news}

end

# NOTE: 2013.2.17. Considering that more tools are coming to re-process formerly collected data, we need a way to process all articles on particular days, 
#   also, this objects can also maintain the some information about experiments already applied. 
class XinMinDailyPageIndexModelForCollector
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  field :page_title, type: String
  field :page_link, type: String
  
  # for use of 'checking if downloaded or not', 'quick retrieving  of particular page', WATCH OUT: if missing a page, leave that empty rather than reusing it.
  field :seq_no, type:Integer
  field :date_of_news, type: Date
  
  scope :on_specific_date, lambda { |date| where(:date_of_news.gte => date, :date_of_news.lte => date+1)  if date }
  scope :with_seq_no, lambda { |seq| where(seq_no: seq) if seq}
  
  index({ date_of_news:1}, { name: "xm_idx_date"} ) 
  index({ date_of_news: 1 , seq_no: 1 }, { unique: true , name: "xm_idx_date_pageindex" })
  
  has_many :articles, class_name:"XinMinDailyArticlesModelForCollector", inverse_of: :pageIndex, autosave: true
  
  validates :seq_no,  :uniqueness => {:scope => :date_of_news}
  validates :article_link,  :uniqueness => {:scope => :pageIndex}

end

# ------------------------------------------------------------------------------------


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
  
    return { 'date_of_news' =>  date.strftime("%Y-%m-%d"), 'pages_links' => pages_and_articles }
  end


  # in var:  date, a date on which the newspaper is available
  # out var: hash, a link-to-page_title mapping (Note: as directory of one day's pages are the same, link only include node_xxx.htm info)
  # e.g. http://xmwb.xinmin.cn/html/2012-10/28/node_1.htm 
  #   is a page-listing web page which contains
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


=begin
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

  def self.grab_news_for_date(dateitem)
  
  end
=end

  def self.grab_news_content(news_url)
  	raw = WebPageTool.retrieve_content(news_url)
      text = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
  	text
  end
 
  # in: page_guide_hash  -  json alike hash, e.g. {:}
  def self.save_toc_hash_as_objmodels(page_guide_hash,force_reload_articles=false, get_content=false)
    date_of_news = page_guide_hash['date_of_news']
    pages_links = page_guide_hash['pages_links']
    one_date = Date.strptime(date_of_news, fmt='%Y-%m-%d')

    pages_links.each_with_index do |page, idx|
      # get page index model
      pgidx_db = XinMinDailyPageIndexModelForCollector.on_specific_date(one_date).with_seq_no(idx).first
      #                                                   ( :date_of_news.gte => one_date,
      #                                                      :date_of_news.lt  => one_date + 1,
      #                                                      :seq_no: idx ).first
      # TODO: why the last 3 commented lines above fails to compile? 
      
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

  # just retrieved
  def self.download_contents_for_date(date)
  end

  # Note: it looks necessary to create relationship between articles and 'page index', so that we can later retrieve a specific articles(see if downloaded or not and other info.)
  def self.download_news_for_date(date)
    # TODO: check if already downloaded or not. 
    toc = XinminDailyCollector.daily_news_links(date)
    toc['pages_links'].each do |page|
    puts "----------  #{page['page_title']}  ---------"
    
      page['articles_links'].each do |article|
        puts "Retrieving #{article['article_title']} : #{article['article_link']}"
        raw = WebPageTool.retrieve_content(article['article_link'])
        article['text'] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
        article['date_of_news'] = Date.strptime(toc['date_of_news'], fmt='%Y-%m-%d')
        #pp art ; puts "-------------------------------"
        #a = XinMinDailyArticlesModelForCollector.new(JSON.parse(article.to_json) )
        #a.save!
      end
    end
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
  
   require File.join(File.dirname(__FILE__),"./text_util.rb")
    puts "starting.."
  all_cnt = 0
  poi_cnt = 0
  page_cnt = 0
  poi = []
  articles_links = []
  links_dict = XinminDailyCollector.daily_news_links(DateTime.new(2013,2,4))
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
=end




=begin
  # -------- for fun: find weibo of those writers whose articles published in the pages named "夜光杯"

    
require File.join(File.dirname(__FILE__),"./wb.bz/util.d/weibo_client.rb")   
    
 links_dict = XinminDailyCollector.daily_news_links(DateTime.new(2012,12,16))
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
 end
=end

=begin

 # -------  command based xinmin article reader, not true, just listing
 # TODO: navigation between pages,  select article by number

    
    links_dict = XinminDailyCollector.daily_news_links(DateTime.new(2013,2,4))
    puts links_dict
    puts "-------------------------------"
    #useful = links_dict['pages_links'].collect{|page|  page if page['page_title'] =~ /要闻/ }
    #puts useful
    #puts "-------------------------------"
    #useful.each do |page|
     links_dict['pages_links'].each do |page|
         #puts page 
        puts "----------  #{page['page_title']}  ---------"
    
        page['articles_links'].each do |art|
            puts "#{art['article_title']} : #{art['article_link']}"
            
            #raw = WebPageTool.retrieve_content(art['article_link'])
            #art[:text] = WebPageTool.locate_text_by_xpath("//div[@id='ozoom']", raw)
            #puts art[:text]
            #puts "-------------------------------"
        end
    
    end
=end




=begin
 ---------------------  test of 'download_news_for_date' methods

  puts "starting..."
  XinminDailyCollector.download_news_for_date(DateTime.new(2013,2,4))
  puts "download_news_for_date... DONE!"  
=end  
  
=begin
 ---------------------  test of 'save_toc_hash_as_objmodels'

  tmp_file = './page_index_hash.yaml'
  unless File.exists? tmp_file
    toc = XinminDailyCollector.daily_news_links(DateTime.new(2013,2,4))
    puts "toc retrieved...."
  
    File.open( tmp_file, 'w' ) do |out|
      YAML.dump( toc , out )
    end
  end
  
  toc = File.open( tmp_file ) { |yf| YAML::load( yf ) }
  # puts "toc: #{toc}"
  
  XinminDailyCollector.save_toc_hash_as_objmodels(toc, force_reload_articles=true, get_content=true )
 
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



