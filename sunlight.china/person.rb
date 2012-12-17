#encoding:UTF-8


# TODO: temp solution, should require a gem!
require File.join(File.dirname(__FILE__),"../wb.bz/util.d/weibo_client.rb")

# placeholder for methods grouping
module SnsDetector

    Sina_Weibo = "sina_weibo"
    
    
end
    
    
# Note: person class will not be created until a real person is inter
class PersonDetector

    
    
    # consider dynamic add this module, so that we starts with a string(namely a person's name in the method-call context), without predefining a Person call, this can be used to further heuristic guessing such like "testing if a string points to a well-known name"
    include SnsDetector
    
    
    def self.weibo_account screen_name
        user = $client.user_show_by_screen_name(screen_name)
        return { Sina_Weibo => user.data }
    end

    
end

if  __FILE__ == $0
    
    
    str = "李开复"
    # str.treat_as_person   # INTENTION: dynamically add module PersonDetector, eg. test if this could be a person with weibo account
    # str.weibo_account
    
    
end


