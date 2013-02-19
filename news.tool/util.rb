#encoding:UTF-8

require 'nokogiri'
require 'mechanize'

class WebPageTool
  def self.retrieve_content(url)
    begin
      m = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      page = m.get(url)
    rescue => e 
      puts "[Error] retrieving #{url} "; puts e.message; puts e.backtrace
      page = nil
    ensure
    #puts page.inspect ; #puts page.content
    end
    return page
  end


  def self.locate_text_by_xpath( xpath , content)
    doc = nil
    if  content.is_a? String
      doc = Nokogiri::HTML(content)
    elsif content.is_a? Mechanize::Page
      doc = Nokogiri::HTML(content.content)
    end

    # TODO: supposed to find only one, refine and warning if more than one 
    node = doc.at_xpath(xpath)
    node.content
  end
end




# -------------------------------------------------------------
# Given a well-intended webpage(e.g. ), find the div tag with most content.
# assuming it has the most useful content for analysis, cut the job of xpath search

# NOTE: target English websites
# -------------------------------------------------------------

# http://stackoverflow.com/questions/2465032/how-can-unwanted-tags-be-removed-from-html-using-nokogiri
module Filter
  def remove_tags!(*list)  # _preserve_content
    xpath('.//*').each do |element|
      if list.include?(element.name)
        element.children.reverse.each do |child|
          # child_clone = child.clone
          # element.add_next_sibling child_clone
          child.unlink
        end
        element.unlink
      end
    end
  end
  
  def remove_non_p_tags!  # _preserve_content
    xpath('.//*').each do |element|
      if "p" != (element.name) 
        element.children.reverse.each do |child|
          # child_clone = child.clone
          # element.add_next_sibling child_clone
          child.unlink
        end
        element.unlink
      end
    end
  end
  
end

class Nokogiri::XML::Element
  include Filter
end

class Nokogiri::XML::NodeSet
  include Filter
end


require 'sanitize'

def choose_by_p_tag_under_div(doc)
  nodes = doc.xpath "//div[not(*[descendant::div]) ]"
  # e.remove_non_p_tags! ; puts "#{e} ------";
  clean_divs = nodes.map{|e| e.remove_non_p_tags!  ;  e }
  .map(&:content)
  .sort{ |a,b| a.length <=> b.length}.reverse
  
  if clean_divs.size > 0
    #puts clean_divs.at(0);  #puts "Total : #{clean_divs.size}"
    clean_divs.at(0)
  else
    nil
  end
end

def choose_by_sanitize_text_under_div(doc)
  nodes = doc.xpath "//div[not(*[descendant::div]) ]"
  
  puts nodes
   # puts "#{e.class}..#{e.length}....." ;
  clean_divs = nodes.map(&:content)
  .map{|e| Sanitize.clean(e) ; e.gsub!(/\s+/, "") ; e  } 
  .sort{ |a,b| a.length <=> b.length}.reverse
  
  if clean_divs.size > 0
    # puts clean_divs.at(0); puts "<<<<<<<"
    clean_divs.at(0)
  else
    nil
  end
end

def guess_content_of_page(content)
  doc = nil
  if  content.is_a? String
    doc = Nokogiri::HTML(content)
  elsif content.is_a? Mechanize::Page
    doc = Nokogiri::HTML(content.content)
  elsif content.is_a? Nokogiri::HTML::Document
    doc = content
  end
  
  
  # TODO: still unsafe, need human intervention! IDEA: compare with page title content!(safe-enough?)
  if doc
    r = choose_by_p_tag_under_div(doc.clone)
    
    if !r || r.gsub(/\s+/,"") == ""
      #puts ">>>>>>>> select by choose_by_sanitize_text_under_div"
      r = choose_by_sanitize_text_under_div(doc.clone) ;            
      r
      else 
      #puts ">>>>>>>> select by choose_by_p_tag_under_div"
      r 
    end
  end
end



