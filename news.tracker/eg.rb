

require 'open-uri'
require 'feed-normalizer'
#require 'erubis'
#require 'mongrel'

=begin
class RSSHandler < Mongrel::HttpHandler
  def process(request, response)
    response.start(200) do |head,out|
      head["Content-Type"] = "text/html"

      stories = []
      File.open('feeds.txt', 'r').each_line { |f|
        feed = FeedNormalizer::FeedNormalizer.parse open(f.strip)
        stories.push(*feed.entries)
      }

      eruby = Erubis::Eruby.new(File.read('news.eruby'))
      out.write(eruby.result(binding()))
	  puts stories.inspect
    end
  end
end

h = Mongrel::HttpServer.new("0.0.0.0", "8001")
h.register("/", RSSHandler.new)
h.run.join


 



url = %Q{http://app.eeo.com.cn/?app=rss&controller=index&action=feed&catid=29}

#File.open('feeds.txt', 'r').each_line { |f|
    feed = FeedNormalizer::FeedNormalizer.parse open(url)
    puts feed.class
    #puts feed.methods.sort
    a = feed.description

    puts feed.items    
#}

=end
        
require 'feedzirra'

# fetching a single feed
feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/PaulDixExplainsNothing")

