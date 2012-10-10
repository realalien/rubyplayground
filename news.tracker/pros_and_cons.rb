#encoding:UTF-8


dev_log "" do |log|
	log.date: 		"2012.9.30,12:21" # Time.now
	log.decision 	"no need "   do 
		pros "probably later mutations on class definitions"
		cons "duplicate code with other entity class, no taking advantage of mongoid lib subclassing"
	end
end