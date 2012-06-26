#encoding:UTF-8
require 'mongoid'

class NewsPiece

    include Mongoid::Document 
    include Mongoid::Timestamps::Created
    
    field :link, type: String   # 链接
    field :content, type: String  # 文章或网页内容（尽量剔除不需要的内容）
    
    
end




module FinancialAccountability
    
end



class AmbiguityNumber
    
    include Mongoid::Document
    
    
end

