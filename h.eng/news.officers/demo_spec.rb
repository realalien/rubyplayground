#encoding:UTF-8



#require "spec_helper"
require "rspec"
require "./demo2.rb"


RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
end


describe "simple and intuitive methods for find names in one article" do
  
  # article for test: http://xmwb.xinmin.cn/html/2013-01/16/content_2_2.htm
  it "should find more than 80% names" do
    expected = ["韩正","习近平","殷一璀","丁薛祥","徐麟","尹弘","王培生","张学兵","周太彤","应勇","陈旭"]
  end

end