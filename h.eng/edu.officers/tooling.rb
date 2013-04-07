#encoding: uTF-8



require 'date'
require 'nokogiri'
require 'json'
require 'mongoid'
require 'yaml'


require 'geocoder'

require File.join(File.dirname(__FILE__),"model.rb")

# http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
YAML::ENGINE.yamler = 'syck'

# Q: any better place for configuration  A:
MONGOID_CONFIG = File.join(File.dirname(__FILE__),"mongoid.yml") 
Mongoid.load!(MONGOID_CONFIG, :development)
Mongoid.logger = Logger.new($stdout)


module Input
    
  def add_persion_with_info(name, text)
    # TODO: avoid to create multiple entities of one real person
    if Person.where(name: name).count > 0
      
    else
      p = Person.new( :name => name)
      t = InfoPiece.new( :text => text )
      p.records << t
      p.save!
    end
  end
   
end  # of module Input

module OrgazationFinder
  
  
  def google_geo(keyword)
    
  end
  
  
end




if __FILE__ == $0
 
  s = Geocoder.coordinates("上海市教育科学研究院")
  pp s
  # use baidu api to confirm or challenge
  
  
#  include Input
  
  # --- test basic input
#  add_persion_with_info("蒋鸣和", "上海市教育科学研究院现代教育实验室主任、研究员，华东师范大学博士研究生")
#  add_persion_with_info("蒋鸣和", "测试姓名重叠")


#  ---- data entry  
#  people_1 = ["郁玉红", "羌莉莉", "许燕", "羌莉莉","陆澄瑛","葛莹","严桑桑","耿靓靚","张志红","顾敏敏","张琛晖","袁亚军","袁娟","金一鸣","徐芳","李诗雯","孔雅萍"]  
#  add_persons(people_1, "嘉定区实验小学教师")


  
end


