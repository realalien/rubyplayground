#encoding:UTF-8

#require 'ostruct'

require File.join(File.dirname(__FILE__),"../wb.bz/util.d/weibo_const.rb")

sns_tooling =<<doc
api:

doc



# -----------------------------------------





# -----------------------------------------


# IDEA: just like the skeumorphism in design, I think this also works in coding
class Dog


  def sniff_profiles name,*sns
    if !sns or sns.size < 2   
      puts "[INFO] you must specify a name and at least one sns website to find profiles"
      return
    end

    candidates_by_sns = {}
    not_ready = []
    
	# idea: better if done in async.
	# idea: better if auto select the API!
	# TODO: hard code judge criteria!
    sns.each do |s|
      if s.to_s.downcase == "weibo"
		# TODO: should search local database first, if not found, then call the API
        candidates = $client.search_suggestions_users name   # return array of hash
		# ProfileManager.load(s).search_by_profile_name(name) #THQ:probably each sns should have its own manager!
	 	candidates_by_sns[s] = candidates if candidates.size > 0

	  elsif s.to_s.downcase == "dianping"
		# since there is no user profile API from dianping, we need either read from local db or grab web page
		candidates = DianPingProfileManager.search_by_user_name name 
		candidates_by_sns[s] = candidates if candidates.size > 0
      elsif s.to_s.downcase == "douban"
          # since there is no user profile API from dianping, we need either read from local db or grab web page
          candidates = DoubanProfileManager.search_by_user_name name 
          candidates_by_sns[s] = candidates if candidates.size > 0  
	  else 
		puts "[INFO] #{s.to_s} API is not ready yet!"
		not_ready << s
	  end		
    end

	candidates_by_sns

  end

end



if __FILE__ == $0

  
# given a random name, eg. from newspaper reporter, find the related sns website
random_name = "milo"  # this text probably gives a collection of user profiles 
dog = Dog.new
candidates = dog.sniff_profiles random_name, :weibo, :douban #hash




# addon: add extra info, eg. profile change_history, text based corresponding profile reasoning (validate by data arbiter)



# find a group of people with a categorical tag, eg. profession tag, role tag




end
