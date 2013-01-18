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
            one_page = { :page_link => "#{pages_dir}/#{row_links[0]['href'].gsub('./','')}"  ,
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
      #puts "pages total #{pages.size}"
      #puts pages
    end  # each index page

  


    return { :date_of_news =>  date.strftime("%Y-%m-%d"), :pages_links => pages }
  end



  def similar_word
    
  end
  
end

def lcs(a, b)
  lengths = Array.new(a.size+1) { Array.new(b.size+1) { 0 } }
  # row 0 and column 0 are initialized to 0 already
  a.split('').each_with_index { |x, i|
    b.split('').each_with_index { |y, j|
      if x == y
        lengths[i+1][j+1] = lengths[i][j] + 1
        else
        lengths[i+1][j+1] = \
        [lengths[i+1][j], lengths[i][j+1]].max
      end
    }
  }
  # read the substring out from the matrix
  result = ""
  x, y = a.size, b.size
  while x != 0 and y != 0
    if lengths[x][y] == lengths[x-1][y]
      x -= 1
      elsif lengths[x][y] == lengths[x][y-1]
      y -= 1
      else
      # assert a[x-1] == b[y-1]
      result << a[x-1]
      x -= 1
      y -= 1
    end
  end
  result.reverse
end



if __FILE__ == $0
  toc = YangtzeDailyCollector.daily_news_links(DateTime.new(2012,12,31))

  
  page_hashes = []
  toc[:pages_links].each do | page|
    page_hashes << page
  end
  
  puts page_hashes
  
  
  similar = {}
  
  word = page_hashes.shift

  
  while page_hashes.size > 0
    
    page_hashes.each do | art|
      s = lcs(word[:page_title].split("：")[1], art[:page_title].split("：")[1])
      if s and not s.gsub(/\s*/,'').gsub(/·/,'').empty? and s.size > 1
        similar[s] ||= []
        title_name = art[:page_title].split("：")[0]
        similar[s] << title_name unless similar[s].include?(title_name)
      end
    end
    word = page_hashes.shift
  end
  
  puts similar
end
