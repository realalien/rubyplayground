#encoding: UTF-8

require 'mongoid'

require File.join(File.dirname(__FILE__), 'models.rb')


# the mongodb setup
YAML::ENGINE.yamler = 'syck'

MONGOID_CONFIG = File.join(File.dirname(__FILE__),"mongoid.yml")
Mongoid.load!(MONGOID_CONFIG, :development)
Mongoid.logger = Logger.new($stdout)



# # --------------------------------------------------

# # give a statistics on community data collected


# # find nearby communities from local databaase



# # demo of workflow
# # e.g. a potential community data from news
# #     ---> check local database (if exists, details from various data providers)


if __FILE__ == $0
    
    
    
    
    
end

