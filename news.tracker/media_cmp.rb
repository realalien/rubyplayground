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
  Allowed_Publisher = { "www.xinmin.cn"=>"新民网", "www.jfdaily.com" => "解放牛网" }  
    
  attr_accessor :raw, :link
  attr_accessor :doc
  def initialize(raw_data, link) # link serves as future replacement fo raw_data that cached locally.
    @raw = raw_data
    @link = link
  end
    
  def get_publisher_by_link_to_front_page
    # TODO: the doc should be reused ! 
     @doc = Nokogiri::HTML(open(@link))  
     nodeset = @doc.xpath("//a[text()='首页']")  #  TODO:  here should depend on locale!
     if nodeset.length > 0
       link_for_name(nodeset[0][:href])  # just find the first
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
      Allowed_Publisher[removed_protocols(link)]
  end
    
    
  def removed_protocols(link)
    link.gsub("http://", "").gsub("https://", "") if link
  end
  
end # of module PublisherDetector

    


# NOTE: it's actually depends on the processing of content
module  OriginalPublisherDetector
    
  attr_accessor :is_original_publisher
    
end # of module  OriginalPublisherDetector
    
    
# NOTE: 
module ContentProcess
  
    def tagging_with_category( tagging,category_name)
      
    end
    
end # of module ContentProcess
    
    
end  # of module ElectricNewsPaperTool


# ---------------------------------------------------------------------------




# TODO:Q: how to include two modules/mixins and do the initialization?
class NewspaperDetector

  include ElectricNewsPaperTool::PublisherDetector

  def initialize(raw_data, link) # link serves as future replacement fo raw_data that cached locally.
	super
  end

end






if __FILE__ == $0
   n = NewspaperDetector.new(jf_news, jf_url)
   puts n.get_publisher  

end


