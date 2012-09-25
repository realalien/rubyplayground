#encoding:UTF-8
require File.join(File.dirname(__FILE__), 'media_cmp.rb')
require "test/unit"
require "shoulda"


class Media_Cmp_Test < Test::Unit::TestCase
  
  context "for www.jfdaily.com" do
    setup do
      jf_url = "http://newspaper.jfdaily.com/xwcb/html/2012-09/09/content_878683.htm"
      @n = NewspaperDetector.new(nil, jf_url)
    end
  
    should "get publisher's name" do
      assert_equal "解放牛网", @n.get_publisher
    end

    should "get author's name" do
      assert_equal "", @n.get_authors[0]
    end

    should "determine if this news is redistributed" do
      assert_equal true, @n.is_redistributed?
    end

    

  end


=begin
  context "for www.xinmin.com" do
    setup do
        url = "http://biz.xinmin.cn/cjds/2012/09/10/16258103.html"
        n = NewspaperDetector.new(nil, url)
    end
  
    should "get publisher's name" do
      assert_equal "新民网", n.publisher
    end
  end

=end

end
