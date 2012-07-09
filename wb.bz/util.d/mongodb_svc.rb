Mongoid.configure do |config|
    name = "mongoid_weibo_dev"
    host = "localhost"
    port = 27017
    config.database = Mongo::Connection.new.db(name)
end
