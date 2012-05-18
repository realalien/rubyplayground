

# a intermediate object to transform the existing models(mongomapper based)
# to models of remote data transfering(e.g. with restful rails)



require 'HTTParty'


# TODO: class name implys a general use, but actually instance is created from instance of Member(mongomapper based),need renaming
class MemberPosterForRestful
	
	include HTTParty
	format :json
	base_uri 'http://localhost:3000'

	
	def self.post_to_restful member
		r = post("http://localhost:3000/account_pois.json" ,:query => {:account_poi => {:account_id => member.dianping_id , :name=>member.name, :sns_name=>"dianping.com"  }}, :options => { :headers => { 'ContentType' => 'application/json' } })
		

		puts "[INFO] #{r.headers['status']}"
	end




end

