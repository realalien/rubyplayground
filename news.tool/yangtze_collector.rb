#encoding:UTF-8


require 'date'
require 'nokogiri'
require 'json'

require File.join(File.dirname(__FILE__),"./util.rb")

class YangtzeDailyCollector
  
  
  # NOTE: because the section/page-titles and article-titles are among different rows of the same table, data will be gathered by processing each row sequentially.
  def self.daily_news_links(date)
    pages_and_articles = []
  
    # http://epaper.yzwb.net/html_t/2012-12/30/node_1.htm
    pages_dir = "http://epaper.yzwb.net/html_t/#{date.year}-#{date.strftime('%m')}/#{date.strftime('%d')}"
    first_index_page = "#{pages_dir}/node_1.htm" # ends with node_1.html
    second_index_page = "#{pages_dir}/node_201.htm"
    
    row_xpath = "//*[@id='layer43']//table/tbody/tr"
  
    one_page = {}  # cache for articles
    pages = []     # container for all hashes of page TOC
  
    # A bundle, B bundle
    [first_index_page, second_index_page].each do | idx|
      index_page = WebPageTool.retrieve_content idx
  
      if index_page
        index_page.parser.xpath(row_xpath).each do | node|
          # test sub <a> node if has 'pageLink' or not
          row_links = node.xpath(".//a[@id='pageLink']")

          if row_links.size == 1  # suppose one for row with page link
            # find new page/section
            pages << one_page unless one_page.empty?
            # refill
            one_page = {}
            one_page = { :page_link => "#{pages_dir}/#{row_links[0]['href']}"  ,
                         :page_title => node.content.gsub("\r\n", "") }
          else
            articles_hash = []
            row_links = node.xpath(".//a") # recollect
            row_links.each do |lnk|
              articles_hash << {:article_link => "#{File.join(pages_dir, lnk['href'].gsub('?div=-1',''))}" ,
                                :article_title => lnk.content.gsub("\r\n", " ") }
            end
            one_page[:articles_links] = articles_hash
          end # of if else
        end # each row

        
      end # if index_page
      puts "pages total #{pages.size}"
      puts pages
    end  # each index page

  


    return { :date_of_news =>  date.strftime("%Y-%m-%d"), :pages_links => pages }
  end

  

end



if __FILE__ == $0
  YangtzeDailyCollector.daily_news_links(DateTime.new(2012,12,31))

end
