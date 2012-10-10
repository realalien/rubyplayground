#encoding:UTF-8


require 'nokogiri'
require 'open-uri'

# get html-formatted daily news
# > get each news links from http://xmwb.xinmin.cn/xmwb/html/2012-09/29/index_2012-09-29.htm

$on_date = Time.local(2012,9,30)
content_page = "http://xmwb.xinmin.cn/xmwb/html/#{$on_date.strftime("%Y-%m")}/#{$on_date.strftime("%d")}/index_#{$on_date.strftime("%Y-%m-%d")}.htm"


def news_links(url)
	links = []
	doc = Nokogiri::HTML(open(url))
	doc.xpath("//a").each do | l |
		if l[:href] =~/^content_\d+_\d+\.htm/
		 	links << %Q[http://xmwb.xinmin.cn/xmwb/html/#{$on_date.strftime("%Y-%m")}/#{$on_date.strftime("%d")}/#{l[:href]}]
		end 
	end
	links
end


def raw_content(url)
	doc = Nokogiri::HTML(open(url))
	xpath = '//*[@id="ozoom"]'
	n = doc.at_xpath(xpath)
	puts n
end


if __FILE__ == $0
	puts content_page
	links = news_links(content_page)
	puts links[0]
	raw_content(links[0])
end