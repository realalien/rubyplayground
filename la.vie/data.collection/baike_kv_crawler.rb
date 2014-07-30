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
  xpath = "//*[@id='content']/p[2]"
  node = doc.at_xpath(xpath)

  raw_attrs = []
  node.children.each do | aNode|
    raw_attrs << remove_blankspaces(URI.unescape(aNode.content)) if aNode.content.strip != ""
  end
 
  cleaned = {}
  raw_attrs.each do |e|
    k,v = e.split("：")
    cleaned[attr_en(k)]=remove_unwanted(v)
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
end


# steps: 
# * check total search result count  
# * check if entry ends with '百科词条'(with detail info, not pic entry)
# * check if it's a neighour
def is_avail(neiborhood_name)
  doc = get_raw_search_page(neiborhood_name)
  # check if has search result count
  xpath="//div[@id='search-wiki']"
  node = doc.xpath(xpath)
  if node.size == 1
    kw = /共搜索到约(\d+)个结果/
    result = node.text.scan(kw).flatten
    if result.size > 0
      puts "Found  ....  #{result.size}"
      # check among result lists
      xp = "//div[@class='result-list']"
      nds = doc.xpath(xp)
      # TODO: pick the best one across pages, now just on the first page
      nds.each do |nd|
        if nds.text =~ /百科词条/ && nds.text =~ /小区介绍/
          # iterate to find link
          nd.css("a").each {|e| puts e['href']}
        end
      end
    end
  end
  
  
end



if __FILE__ == $0
  #p =  get_raw_page("虹口现代公寓")
  #puts p
  #pp get_attrs(p)
  
  is_avail("中信和平家园")
  puts "------"
  #is_avail("中信和平家园xx")
  
end




