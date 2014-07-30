#encoding:UTF-8

require 'uri'
require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'yaml'
require 'pp'

require File.join(File.dirname(__FILE__), '../../hackingLBS/ddmap_resources.rb')

def link_on_baike(entry_name)
  return "http://www.baike.com/wiki/"+URI.encode_www_form_component(entry_name)
end


def search_on_baike(entry_name)
  return "http://so.baike.com/s/doc/" + "#{URI.encode_www_form_component(entry_name)}" + "&prd=button_doc_search"
end

def get_raw_page(neiborhood_name)
  one_doc = Nokogiri::HTML(defense_requests_control(link_on_baike(neiborhood_name)))
end

def get_raw_search_page(keyword)
  one_doc = Nokogiri::HTML(defense_requests_control(search_on_baike(keyword)))
end


def remove_blankspaces(str)
  str.strip.gsub("　","")
end

def remove_unwanted(str)
  u = {";;" => ";"}
  s = str
  u.each{|k,v| s = s.gsub(k,v) }
  s
end

def get_attrs(doc)
  xpath = "//*[@id='content']/p"
  nodes = doc.xpath(xpath)
  return nil unless nodes
  puts nodes.size
  puts nodes[1]
  raw_attrs = []
  cleaned = {}
  nodes.each do |node|
    if node
      node.children.each do | aNode|
        raw_attrs << remove_blankspaces(URI.unescape(aNode.content)) if aNode.content.strip != ""
      end
      puts "#{raw_attrs}"
     
      raw_attrs.each do |e|
        k,v = e.split("：")
        cleaned[attr_en(k)]=remove_unwanted(v) if k and v
      end
      cleaned
    else
      nil
    end
  end
  cleaned
end

$ATTRS_CH_TO_EN = {
 "区域"=>"area",
 "板块"=>"locality",
 "物业公司"=>"mgmt",
 "物业费"=>"fee",
 "建筑年代"=>"built_at",
 "物业类别"=>"type",
 "容积率"=>"FAR",
 "建筑类型"=>"highness",
 "绿化率"=>"greenness",
 "停车位"=>"parking_lots",
 "总户数"=>"houses",
 "建筑面积"=>"bld_sq"
 }
 
def attr_en(attr_cn)
  $ATTRS_CH_TO_EN[attr_cn] if $ATTRS_CH_TO_EN.has_key?(attr_cn)
  attr_cn
end


# steps: 
# * check total search result count  
# * check if entry ends with '百科词条'(with detail info, not pic entry)
# * check if it's a neighour
def best_baike_link(neiborhood_name)
  doc = get_raw_search_page(neiborhood_name)
  # check if has search result count
  xpath="//div[@id='search-wiki']"
  node = doc.xpath(xpath)
  if node.size == 1
    kw = /共搜索到约(\d+)个结果/
    result = node.text.scan(kw).flatten
    if result.size > 0
      #puts "Found  ....  #{result[0]} similar entries."
      # check among result lists
      xp = "//div[@class='result-list']"
      
      links = []
      nds = doc.xpath(xp)
      # TODO: pick the best one across pages, now just on the first page
      nds.each do |nd|
        if nd.text =~ /百科词条/ and nd.text =~ /小区介绍/ and nd.text.scan(neiborhood_name).size>0
          # iterate to find link
          nd.css("a").each {|e| links << e['href']}
        end
      end
      
      clean_position(links)
      
    end
  end  
end



def clean_position(arr)
  cleaned = []
  arr.each do |a|
    c = a.gsub(/[#|\?].*/, "")
    cleaned << c unless cleaned.include? c
  end
  cleaned
end


def grab_attrs(neighborhood_name)
  #arr = best_baike_link(neighborhood_name)
  #if arr and arr.first == link_on_baike(neighborhood_name)
    get_attrs(get_raw_page(neighborhood_name))
  #else
  #  nil
 # end
end




if __FILE__ == $0
  #p =  get_raw_page("虹口现代公寓")
  #puts p
  #pp get_attrs(p)
  
  #puts best_baike_link("恒业公寓")  # 中信和平家园
  puts "------"
  #best_baike_link("中信和平家园xx")
  
  #puts link_on_baike("恒业公寓")
  
  #puts grab_attrs("恒业公寓")
  
  puts grab_attrs("华清名苑")
  
  #  ------------  bulk retrieving  -----------------
  # read from files
 
=begin 
  all_hk = []
  dict = JSON.parse( IO.read(File.join(File.dirname(__FILE__), 'sh_hk_neighbourhood.json')) )
  dict.each_pair do |k,v|
    puts "Processing ....  #{k}"
    attrs = grab_attrs(k) 
    if attrs
       c = [k]
       c << attrs.values
       c.flatten
       puts c.join("|")
       all_hk << c.join("|")
    end
  end
  
  puts all_hk
=end  
  
end




