#encoding: uTF-8


require File.join(File.dirname(__FILE__),"model.rb")

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


require 'geocoder'

if __FILE__ == $0
 
  s = Geocoder.coordinates("上海市教育科学研究院")
  pp s
  
#  include Input
  
  # --- test basic input
#  add_persion_with_info("蒋鸣和", "上海市教育科学研究院现代教育实验室主任、研究员，华东师范大学博士研究生")
#  add_persion_with_info("蒋鸣和", "测试姓名重叠")
  
  
end

