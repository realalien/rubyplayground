#encoding:UTF-8



#require "spec_helper"
require "rspec"
require "./news_parallel.rb"

RSpec.configure do |config|
    config.color_enabled = true
    config.tty = true
    config.formatter = :documentation
end





describe "NewsPapersTools in dev" do
  
    it "should report missing tool" do
      r = NewsPapersTools.report_similar_sections(:XinminDaily, :LaoDongDaily)
      r.should_not be_empty
      r.should eql ["LaoDongDailyCollector"]
    end
    
  
    
    # TODO: more sns tests
    
end