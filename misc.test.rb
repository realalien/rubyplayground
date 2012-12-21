

require '../edu_catcher.rb'

class FindChineseAddressTest < Test::Unit::TestCase

    def test_accurary
        assert_equal( find_chinese_addr("台北市汀州路三段230巷14弄2號") , "" )
    end
    
end

