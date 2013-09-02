#encoding:UTF-8


require 'mongoid'

# the mongodb setup
YAML::ENGINE.yamler = 'syck'

MONGOID_CONFIG = File.join(File.dirname(__FILE__),"mongoid.yml")
Mongoid.load!(MONGOID_CONFIG, :development)
Mongoid.logger = Logger.new($stdout)
