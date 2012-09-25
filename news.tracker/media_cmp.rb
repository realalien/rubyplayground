#encoding:UTF-8


# Purpose:
# * Find the origin source(probably with least information lost), better if we can tell the distributors which can be later analysed for other purposes
# * Compare the content of the same topic among media distributors





#
# e.g. from xm_news, we can read it's source/distributors among 



# a class who keep the knowledge of different media's process rules like where to find the target data and how 

require 'nokogiri'
require 'open-uri'


module ElectricNewsPaperTool
    
    
module PublisherDetector  
  Allowed_Publisher = { "www.xinmin.cn"=>"新民网", "www.jfdaily.com" => "解放牛网",
                        "www.eeo.com.cn" => "经济观察网" }
    

    
  def get_publisher_by_link_to_front_page
    # TODO: the doc should be reused ! 
     if @raw 
       @doc = Nokogiri::HTML(@raw)  
     elsif @link
       @doc = Nokogiri::HTML(open(@link))    
     end 
     
     if @doc
       nodeset = @doc.xpath("//a[text()='首页']")  #  TODO:  here should depend on locale!
       #puts nodeset
       if nodeset.length > 0
         link_for_name(nodeset[0][:href])  # just find the first
       end
     end
  end      

  
  def get_publisher_by_page_meta_data
      
  end
    
  # run through get_publisher_by_xxxx methods to pindown the user
  def get_publisher
    # TODO: temporary solution for one publisher
    get_publisher_by_link_to_front_page
  end
  
  def link_for_name(link)
      Allowed_Publisher[clean_for_domain(link)]
  end
    
    
  def clean_for_domain(link)
    link.gsub("http://", "").gsub("https://", "").gsub("/","") if link
  end
  
end # of module PublisherDetector

    


# NOTE: it's actually depends on the processing of content
module  OriginalPublisherDetector
    
  attr_accessor :is_original_publisher
    
end # of module  OriginalPublisherDetector
    
    
# NOTE: 
module ContentProcess
  
    def ensure_doc
      unless @doc
        if @raw 
          @doc = Nokogiri::HTML(@raw)  
        elsif @link
          @doc = Nokogiri::HTML(open(@link))    
        else
          nil
        end
      else
        @doc
      end 
    end
  
    # NOTE:TODO:Q: how to embed another module which shares one instance variable? 
    #def get_content  ; end
  
    # NOTE: to find the authors for different newspaper is a little hard because the text is embedded in the article, and to distinguish the author's name(s), we depend on the text ahead of the names, such like "记者", "特约评论员" and many unexpected roles in reporting. 
    # NOTE: if machine fails to do the job(of course not regularly), human intervention should be introduced, e.g. ask human to find the author. 
    def get_authors
      ensure_doc
    end
  
    def tagging_with_category( tagging,category_name)
      
    end
    
end # of module ContentProcess
    
    
end  # of module ElectricNewsPaperTool


# ---------------------------------------------------------------------------




# TODO:Q: how to include two modules/mixins and do the initialization?
class NewspaperDetector

  include ElectricNewsPaperTool::PublisherDetector

  # NOTE: the module will be cross-referenced, not nice as API design
  #include ElectricNewsPaperTool::ContentProcess
  
  #  def initialize(raw_data, link) # link serves as future replacement fo raw_data that cached locally.
	#super
  #end
  
  attr_accessor :raw, :link
  attr_accessor :doc
  def initialize(raw_data, link) # link serves as future replacement fo raw_data that cached locally.
    @raw = raw_data
    @link = link
  end
  
  
  def get_content 
    pub = get_publisher
    if pub == "解放牛网"
      xpath = "//div[@class='content']" 
      node = @doc.at_xpath(xpath)
      @content =  node.content
    elsif pub == "经济观察网"
      xpath = "//div[@id='text_content']" 
      node = @doc.at_xpath(xpath)
      @content =  node.content
    elsif pub == "新民网"
      
    else 
      puts "[WARNING] we can't handle newspaper from the publisher: #{pub}"
    end
  end
  
  
  def get_authors
    
  end

  def get_audit_number
    
  end
  
  
end








if __FILE__ == $0
   jf_url = "http://newspaper.jfdaily.com/xwcb/html/2012-09/09/content_878683.htm"
   jf_url = "http://www.eeo.com.cn/2012/0725/230631.shtml"
   n = NewspaperDetector.new(nil, jf_url)
   #puts n.get_publisher  
   puts n.get_content
end


