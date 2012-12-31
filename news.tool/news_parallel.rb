#encoding:UTF-8


def class_exists?(class_name)
  klass = Module.const_get(class_name)
  return klass.is_a?(Class)
rescue NameError
  return false
end


#Purpose:  find the similarity between the newsspaper to find the diff and detail



# temp code, better if load dynamically
require './xinmin_collector.rb'


# this module is supposed to provide tools targeting on multiple source of newspapers
module NewsPapersTools
  
  
  # IDEA: enforce and test out the individual newspaper tool!!
   
  
  # find common section/page among several newspaper, can be used to as shortcut for finding potential similar articles
  def self.report_similar_sections(*newspaper_identities)
    to_cmp = []
    missing_tool = []
    # SUG(delay): load required corresponding module for tooling
  
    # identify the valid ones with corresponding tools
    newspaper_identities.each do | name |
      tool_name = "#{name.to_s}Collector"
  
      if class_exists?(tool_name)
        to_cmp << tool_name
      else 
        missing_tool << tool_name
        puts "[WARN] #{tool_name} is not available!"
      end
    end
   
    # get page/article index of newspaper (on a target day in case page varies) 
     
   
    to_cmp #missing_tool
    
  end

  
  
end # of module





if __FILE__ == $0


# 1.0  find similar 'sections' between two newspapers, e.g. xm, whb, so that we can limit the text parsing context.

  s = report_similar_sections(:XinMinDaily, :LaoDongDaily)
    # [:XinMinDaily, :LaoDongDaily].similar_sections  # TODO: what's best practices in extending array?
    
    

    # Addon: incorporate manul/human intervention for strong connection based on similarity.    
    
    
# 1.1  find similar ariticles
    

    
    
# Q: how to index the news paper? and stored for later use? solr?    

    

end


