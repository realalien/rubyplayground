#encoding:UTF-8

#require 'ostruct'

sns_tooling =<<doc

api:
  


 

doc


# IDEA: just like the skeumorphism in design, I think this also works in coding
class Dog


  def sniff_profiles *sns
    if !sns or sns.size <=0    
      puts "[INFO] you must specify at least sns website to find profiles"
      return
    end

    candidates_by_sns = {}
    not_ready = []
    
    sns.each do |s|
      if s.to_s

    end


  end

end



if __FILE__ == $0

  
# given a random name, eg. from newspaper reporter, find the related sns website
random_name = "milo"  # this text probably gives a collection of user profiles 
dog = Dog.new
candidates = dog.sniff_profiles :weibo, :twitter #hash




# addon: add extra info, eg. profile change_history, text based corresponding profile reasoning (validate by data arbiter)



# find a group of people with a categorical tag, eg. profession tag, role tag




end
