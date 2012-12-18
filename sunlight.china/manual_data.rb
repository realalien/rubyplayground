#encoding:UTF-8

#TODO:VIP: find the best way to group the data collect manually.
#IDEA: find a way to avoid overwriting existing variables.

#module ManualData
    
# ---------------------------------------
# Shanghai Workers Union (governing body)
# Note: inspired by http://goo.gl/FM9MT , with some manual Google searches
# ---------------------------------------
org =  {
    "name" =>  "上海市总工会", "website" => "www.shzgh.org"
}


org["sub-organizations"] = [
    { "name" =>  "金山区总工会", "website" => "zgh.jinshan.gov.cn" },
    { "name" =>  "闵行区总工会", "website" => "mhzgh.shmh.gov.cn" },
    { "name" =>  "青浦区总工会", "website" => "tu.shqp.gov.cn" },
    { "name" =>  "嘉定区总工会" },
    { "name" =>  "松江区总工会" },
    { "name" =>  "南汇区总工会" },
    { "name" =>  "奉贤区总工会" },
    
    { "name" =>  "普陀区总工会", "website" => "www.ptzgh.org" },
    { "name" =>  "虹口区总工会", },
    { "name" =>  "闸北区总工会", },
    { "name" =>  "宝山区总工会", },
    { "name" =>  "杨浦区总工会", "website" => "www.shypzgh.org" },
    
    { "name" =>  "长宁区总工会", "website" => "www.cngh.org" },
    { "name" =>  "徐汇区总工会", "website" => "zgh.xh.sh.cn" },
    { "name" =>  "黄浦区总工会", "website" => "www.hpzgh.org" },
    { "name" =>  "卢湾区总工会" },
    { "name" =>  "静安区总工会" },
    
    { "name" =>  "浦东新区总工会", "website" => "gonghui.pudong.gov.cn" },
]


# ---------------------------------------
# Shanghai Workers Union's affliated support organizations and people
# source: http://goo.gl/zHPNU
# ---------------------------------------
    
# Note: This class is just for data grouping, therefore make it easy to
#  * transform data to target formats of data output (eg. json, xml)
#  * data validation  (eg. duplication)
#  * data relationship mining and experimenting

Org = Struct.new(:name) 
Pro = Struct.new(:org_name, :role_name, :person_name)    
Rule = Struct.new(:name) 
    
    
pros = [
    Pro.new("上海市总工会", "主席", "钟燕群"),
    Pro.new("上海市总工会", "秘书长", "张立群"),
    Pro.new("上海市总工会", "副主席", "茆荣华"),
    Pro.new("上海市司法局", "副局长", "蔡永健"),
    Pro.new("上海律师协会", "会长", "盛雷鸣"),
    Pro.new("上海市司法局律师管理处", "处长", "马屹"),
    Pro.new("上海律师协会", "副秘书长", "刘小禾"),
    Pro.new("上海律师协会业务部", "主任", "潘瑜"),
    Pro.new("上海律师协会劳动法业务研究委员会", "副主任","陆敬波"),
    Pro.new("江三角律师事务所", "主任", "陆敬波"),
    Pro.new("第三届法律顾问团", "成员", "陆敬波"),
    Pro.new("上海市总工会", "副书记", "肖堃涛"),
    Pro.new("上海市总工会", "副主席", "肖堃涛")
] 
        
    
org_mentioned = [ Org.new("上海市总工会第三届法律顾问团"),
    
] 
    
rules_mentioned = [
    Rule.new("聘请上海市总工会第三届法律顾问团成员的决定"),
    Rule.new("成立“上海工会职工法律援助维权服务志愿团”的决定")
    
]

pros_affliates = [
    Pro.new('中茂所', '律师','盛雷鸣'),
    Pro.new('尚伟所', '律师','黄绮'),
    Pro.new('钱翊樑所','律师','钱翊樑'),
    Pro.new('四维乐马所','律师','厉明'),
    Pro.new('君悦所','律师','刘正东'),
    Pro.new('恒信所','律师','鲍培伦'),
    Pro.new('君合上海所','律师','马建军'),
    Pro.new('申汇所','律师','李家麟'),
    Pro.new('三石所','律师','沈伟明'),
    Pro.new('保华所','律师','孙为新'),
    Pro.new('融孚所','律师','吕琰'),
    Pro.new('蓝白所','律师','陆胤'),
    Pro.new('天一所','律师','张善美'),
    Pro.new('江三角所','律师','陆敬波'),
    Pro.new('廖得所','律师','廖佩娟'),
    Pro.new('中夏旭波所','律师','朱素宝'),
    Pro.new('大成上海所','律师','徐郭飞')
]

=begin
def linked_infos
    sug "找到并跟踪，其它多届顾问团及未来的法律顾问团成员，及其成员工作记录"  do 
        based_on  "市总工会继2006年建立法律顾问团"
        # fill in with tools
    end
end    
 
def notes
    note "将更多更好地运用社会资源，发挥其在工会参与立法、协调劳动关系、维护职工合法权益中的积极作用，切实为本市广大职工提供专业法律服务。", "goals" # potential  target for auditing 
    note "盛雷鸣会长在讲话中指出，律师作为拥有法律知识和专业技能的社会主义法律工作者、法律援助践行者，在维护职工合法权益，救助困难职工群体、维护社会公平正义，促进社会和谐稳定中，理应成为职工合法权益的代言人、维护者，这是时代赋予律师的神圣使命。", "propositions" # potential for learning, mimicking
    note "第三届20名顾问团成员， 市总工会还聘请100名以上海律师为主的优秀法律人才和社会热心人士为上海工会法律援助维权服务志愿团成员"
    note "上海律协还将与市总工会在参与立法、制订市委市政府相关法律法规政策方面进行进一步的合作。", "knowledge"  # knowledge of law strcture and 
end
 
def extra
    sug "找到其它的律师" do
        based_on "人工阅读微博内容，其对话的参与者及参与者screen_name带律师字样"
    end
 
    sug "确定并肯定关联的微博是其本人" do
        based_on "人工阅读微博内容，关注者和被关注者的职业划分"
    end
end
 
=end
    
#end
    
    
    
    
    
    
if  __FILE__ == $0
   

    # ---- for fun: see if those lawyers has weibo
    #include ManualData
    
    require File.join(File.dirname(__FILE__),"../wb.bz/util.d/weibo_client.rb") 
    # sug: too many same name persons in weibo, should use organization as criteria for searching
    pros_affliates.each do |pro|
        author = pro.person_name
        puts "Detecting weibo account for #{author}"
        begin 
            user = $client.user_show_by_screen_name(author).data
            puts "#{user['screen_name']}  #{user['id']} " 
        rescue 
            puts "#Couldn't find weibo info by screen_name #{author}"  
        end   
    end
    
    
    
end
    
    
