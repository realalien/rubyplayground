#encoding:UTF-8

=begin

	# -----------------  use case (simple data entry) ------------------
	

=end

require File.join(File.dirname(__FILE__), "manpower.rb")
	#a = Individual.create!(:name_cn => "殷一璀", :description_first_met=> "新民晚报A4, 上海市总工会举办专题座谈", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "上海市市委", :role => "副书记" }]
	#a.save

	# 市人大常委会副主任、市 总工会主席钟燕群主持会议
	#a = Individual.create!(:name_cn => "钟燕群", :description_first_met=> "新民晚报A4, 上海市总工会举办专题座谈", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "上海市人大常委会", :role => "副主任" }, 
	#			{ :organzation => "上海市总工会", :role => "主席" }]
	#a.save

	#本报讯(记者 xx)
	#a = Individual.create!(:name_cn => "施捷", :description_first_met=> "新民晚报A4", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "新民晚报", :role => "首席记者" }]
	#a.save

	#市红十字会常务副会长马强 为被遗弃拐卖者寻找“娘家人”——市红十字会负责人谈为离散者提供网上寻亲服务
	#a = Individual.create!(:name_cn => "马强", :description_first_met=> "新民晚报A4 为被遗弃拐卖者寻找“娘家人”——市红十字会负责人谈为离散者提供网上寻亲服务", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "上海市红十字会", :role => "常务副会长" }]
	#a.save

	# http://www.shfao.gov.cn/wsb/node270/node352/node354/index.html
	#a = Individual.create!(:name_cn => "朱建中", :description_first_met=> "首页 >> 外办介绍 >> 领导名单 http://www.shfao.gov.cn/wsb/node270/node352/node354/index.html", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "上海市人民政府外事办公室", :role => "副巡视员", 
	#		:descision => "协助分管新闻工作，协助做好办“三定”工作。"}]
	#a.save

# ---------------------------------------------------------
# http://www.shfao.gov.cn/wsb/node270/node352/node354/index.html
=begin
class Hash
  def deep_include?(sub_hash)
    sub_hash.keys.all? do |key|
      self.has_key?(key) && if sub_hash[key].is_a?(Hash)
        self[key].is_a?(Hash) && self[key].deep_include?(sub_hash[key])
      else
        self[key] == sub_hash[key]
      end
    end
  end
end

doc=<<DOC
上海市人民政府办公厅主任           洪 浩          
上海市发展和改革委员会主任        周 波
上海市经济和信息化委员会主任       戴海波         
上海市商务委员会主任              沙海林
上海市教育委员会主任               薛明扬          
上海市科学技术委员会主任          寿子琪
上海市民族和宗教事务委员会主任     赵卫星         
上海市公安局局长                  张学兵
上海市监察局局长                   顾国林          
上海市民政局局长                  马伊里
上海市司法局局长                   吴军营          
上海市财政局局长                  蒋卓庆
上海市人力资源和社会保障局局长     周海洋          
上海市城乡建设和交通委员会主任    黄 融
上海市农业委员会主任               孙 雷          
上海市环境保护局局长              张 全
上海市规划和国土资源管理局局长     冯经明         
上海市水务局局长                  张嘉毅
上海市文化广播影视管理局局长       胡劲军          
上海市卫生局局长                   徐建光          
上海市人口和计划生育委员会主任    黄  红
上海市审计局局长                   宋依佳          
上海市人民政府外事办公室主任      李铭俊
上海市国有资产监督管理委员会主任   王 坚          
上海市地方税务局局长              顾  炬
上海市工商行政管理局局长           吴振国          
上海市质量技术监督局局长          黄小路
上海市统计局局长                   王建平          
上海市新闻出版局局长              方世忠           
上海市绿化和市容管理局局长         马云安          
上海市住房保障和房屋管理局局长    刘海生
上海市交通运输和港口管理局局长     孙建平          
上海市体育局局长                  李毓毅
上海市旅游局局长                   道书明          
上海市知识产权局局长              吕国强
上海市安全生产监督管理局局长       齐 峻          
上海市人民政府机关事务管理局局长  薛晓峰
上海市民防办公室主任               沈晓苏          
上海市人民政府合作交流办公室主任  林  湘
上海市人民政府侨务办公室主任       徐  力          
上海市人民政府法制办公室主任      刘  华
上海市人民政府研究室主任           张道根          
上海市金融服务办公室主任          方星海
上海市政府口岸服务办公室主任       张超美          
上海市人民政府新闻办公室主任      朱咏雷
上海市世博会事务协调局局长         洪  浩          
上海市人民政府参事室主任          王新奎
上海市粮食局局长                   张新生          
上海市监狱管理局局长              桂晓民
上海市食品药品监督管理局局长       徐建光          
上海市社团管理局局长              华 源
上海市公务员局局长                 应雪云
DOC
# http://www.shanghai.gov.cn/shanghai/node2314/node2319/node11494/node12328/index.html

expect_roles = ["局长", "主任"]
names = []
cnt = 0
doc.each_line do |l|
   e = l.split(/\s+/)

   e1 = e.shift
   #puts e1

   if e1 =~ /局长|主任/
   	  #puts e1.gsub(/局长|主任/, "")
   	  org = e1.gsub(/局长|主任/, "")
   	  role = $&  # $& contains the matched string from the previous successful pattern match.
   else
   	  puts "#{e1} can't parsed"
   end

   e2 = e.join("").gsub(/\s+/, "").gsub(" ","")
   #puts e2
   name = e2


   # check name duplicated
   unless names.include? name
   	 names << name
   else
   	 puts "#{e1} #{name} has found dulplicated"
   end


   begin
   puts ">#{org},#{role},#{name}<"
   a = Individual.create!(:name_cn => "#{name}", :description_first_met=> "首页 >> 政府信息公开 >> 市政府信息公开目录 >> 市政府及其工作机构的领导名单 市政府各委办局主要负责人 http://www.shanghai.gov.cn/shanghai/node2314/node2319/node11494/node12328/index.html", :location_first_met => "Shanghai")
   a.roles = [{ :organzation => "#{org}", :role => "#{role}" }]
   a.save
   rescue Mongoid::Errors::Validations => e

   b = Individual.where(:name_cn => name)
   	 if b.count > 0
   	 	cnt += 1
   	 	puts b.first.name_cn
   	 	c = b.first
   	 	if 	c.roles.include?({:organzation => "#{org}",:role => "#{role}"})
   	 		puts ">>>Found"
   	 	else 
   	 		puts ">>> NOT FOUND"
   	 	end
   	 	#c.roles << { :organzation => "#{org}", :role => "#{role}" }
   	 	#c.save
   	 else 
   	 	#puts "[Error] expected: #{name}, but not found in db"
   	 end
  

end

   # debugging
   puts cnt
   b = Individual.where(:name_cn => "徐建光")
   puts b.count
   b.each { | l | puts l.name_cn; puts l.roles; puts l._id}
=end 


# ---------------------------------------------------------

=begin
doc2 =<<EOF
市长:韩正
常务副市长:杨雄
副市长: 屠光绍 艾宝俊 沈骏 沈晓明 赵雯 姜平 
副秘书长: 王伟 肖贵玉 翁铁慧 薛潮 陈靖
EOF
# duplicate in db:
#副市长: 张学兵
#秘书长: 洪浩 
#副秘书长: 周波 蒋卓庆 

doc2.each_line do |l|
  e = l.strip.split ":"
  if e.size == 2
	  role = "#{e[0].strip}"

	  e1 = e[1]
	  names = e1.split /\s+/

	  names.each do |n|
	  	  n = n.strip
	  	  if not n.empty?
	  	  	crt = Individual.where(:name_cn => n)
		  	if crt.count > 0
	       	  puts "#{n} might already in db, removed and add manually!"
		 	
	       	else 
		  		puts "ADDING   >#{role}, #{n}<"
		 	 	a = Individual.create!(:name_cn => "#{n}", :description_first_met=> "首页 >> 政府信息公开 >> 市政府信息公开目录 >> 市政府及其工作机构的领导名单 市政府各委办局主要负责人 http://www.shanghai.gov.cn/shanghai/node2314/node2319/node11494/node12328/index.html", :location_first_met => "Shanghai")
	   	  		a.roles = [{ :organzation => "上海市市政府", :role => "#{role}" }]
	   	  		a.save
	   	  	end
	  	  end
	  end
  end
end



doc3=<<EOF
浦东新区区长   姜樑       
徐汇区区长    过剑飞
长宁区区长    李耀新       
普陀区区长    孙荣乾
闸北区区长       翁祖亮      
虹口区区长    吴清
杨浦区区长    金兴明       
黄浦区区长    周伟  
静安区区长       周平       
闵行区区长    莫负春
宝山区区长        汪泓       
嘉定区区长       马春雷    
松江区区长        俞太尉       
青浦区区长      赵惠琴
金山区区长       李跃旗       
奉贤区区长       庄少勤  
崇明县县长    赵奇
EOF

doc3.each_line do |l|
  e = l.strip.split /\s+/
  if e.size == 2
	  role = "#{e[0].strip}"
	  	  n = e[1].strip
	  	  if not n.empty?
	  	  	crt = Individual.where(:name_cn => n)
		  	if crt.count > 0
	       	  puts "#{n} might already in db, removed and add manually!"
		 	
	       	else 
		  		puts "ADDING   >#{role}, #{n}<"
		 	 	a = Individual.create!(:name_cn => "#{n}", :description_first_met=> "首页 >> 政府信息公开 >> 市政府信息公开目录 >> 市政府及其工作机构的领导名单 市政府各委办局主要负责人 http://www.shanghai.gov.cn/shanghai/node2314/node2319/node11494/node12328/index.html", :location_first_met => "Shanghai")
	   	  		a.roles = [{ :organzation => "上海市市政府", :role => "#{role}" }]
	   	  		a.save
	   	  	end
	  	  end

  end
end

=end

# ---------------------------------------------------------
	#a = Individual.create!(:name_cn => "曾志凌", :name_en=> "John Zeng",:description_first_met=> "日本丰田在华工厂被迫减产 http://www.ftchinese.com/story/001046746", :location_first_met => "Shanghai")
	#a.roles = [{ :organzation => "LMC Automotive", :role => "researcher" }]
	#a.save

#a = Individual.create!(:name_cn => "何黎",:description_first_met=> "日本丰田在华工厂被迫减产 http://www.ftchinese.com/story/001046746", :location_first_met => "Shanghai")
#	a.roles = [{ :organzation => "www.ftchinese.com", :role => "译者" }]
#	a.save


#a = Individual.create!(:name_cn => "杨宇霆",:description_first_met=> "中国央行节前投放大量流动性 http://www.ftchinese.com/story/001046795", :location_first_met => "-")
#a.roles = [{ :organzation => "澳新银行ANZ", :role => "经济学家" }]
#a.save

#a = Individual.create!(:name_cn => "吴光",:description_first_met=> "重庆市经信委：科学审批严格管理民企专项资金 http://www.eeo.com.cn/2012/0930/234326.shtml", :location_first_met => "Chongqing")
#a.roles = [{ :organzation => "重庆市经济和信息化委员会", :role => "副主任" }]
#a.save



#a = Individual.create!(:name_cn => "余永定",:description_first_met=> "分析：人民币跨境贸易结算吸引力上升http://www.ftchinese.com/story/001046737", :location_first_met => "Shanghai")
#a.roles = [{ :organzation => "中国社会科学院", :role => "学部委员" }]
#a.save

a = Individual.create!(:name_en => "Andrew Jaspan",:description_first_met=> "A New Way to Do Journalism: Andrew Jaspan at TEDxCanberra 2012 http://www.youtube.com/watch?v=SMGqpikuVEQ&feature=g-all-u", :location_first_met => "Australia")
a.roles = [{ :organzation => "The Conversation", :role => "executive Director" },
		{ :organzation => "The Conversation", :role => "editor" },
		{ :organzation => "The Conversation", :role => "co-founder" }]
a.save

n = "Andrew Jaspan"
crt = Individual.where(:name_en => n)
if crt.count > 0
  puts "'#{n}' might already in db, removed and add manually! #{crt.first.name_cn}, #{crt.first.roles}"
end



