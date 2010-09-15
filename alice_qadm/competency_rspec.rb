

# I think one way to extract intelligence from other experience 
# *  keep each item in text format, so that programmer can decide 
#    if to treat the item as first class citizen or other levels
# *  Or morph the existing design into other code structures
# 
# *  Maybe programs should not concern about the real concepts,
#    but about speed and logic

require 'rubygems'
require 'shoulda' # the reason choosing shoulda over rspec that I think  'context' can be used to offer more semantics


# Note: it's not test for humans, but for functionalities of
class CompetencyTest < Test::Unit::TestCase
  context "A competent qa programmer or data manager" do
    setup do
        
    end
    context "at level A" do# though it looks like there is no need to discriminate levels 
      setup do
        # configure system to level A
      end
    
      should " has basic knowledge of game development process" do
         # just test public interface, not deep knowledge probably
         # should have at least 2 assertions, one assertion for respond_to?, 
         # one for testing input data (that's huge).

         assert true
      end
    
      should " has basic knowledge of the different workflows: graphic, animation, level design, sound, etc. depending on the stage of the production " do
                
      end
      
      should " has good knowledge of bug tracking systems (database)." do 
        
      end
      
      
      
    
    end
  end
end


class CompetencyJudgeAgent
    
end



