#encoding:UTF-8



#require "spec_helper"
require "rspec"
require "./person.rb"

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
end



# NOTE: entities info for testing is retrieved from http://goo.gl/zHPNU
describe PersonDetector do
    
    it "should report sina-weibo account hash, given an screen name in existance" do
        w = PersonDetector.weibo_account "李开复"
        w.should have_key(SnsDetector::Sina_Weibo)
        w[SnsDetector::Sina_Weibo].should_not be_empty
        w[SnsDetector::Sina_Weibo].should be_an_instance_of(Hash) 
        
        # puts w[SnsDetector::Sina_Weibo]; puts "---------";
        w[SnsDetector::Sina_Weibo].should have_key("id")
        w[SnsDetector::Sina_Weibo]["id"].should be_an_instance_of(Fixnum) 
    end
    
    
    it "should report empty " do 
    
    end
    
    # TODO: more sns tests
    
end

