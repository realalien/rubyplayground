#encoding:UTF-8
require 'httparty'

include HTTParty

def get_jieba_seg(text)
	HTTParty.post("http://localhost:8081/jiebacut", {:body => {'text'=> text }} )

end


get_jieba_seg("但是ferret本身并没有提供中文分词功能，必须自己另行扩展中文分词功能")
