
# Purpose: 
# Design code for modeling a life cycle of a normal/regular human,
# in order to create a tool for assist next generations with help
# from machine. 

# Note :
# * 
# * 20100828, the first thought is to create a state machine code structure
# * 20100828, since a human life can be a very large state machine, it is assumed
#             that from beginning the state machine to achieve small scale of part of life.
# * 20100828, Q: what about a timeline implementation? Maybe useful in presentation and visualization.
# * 20100906, IDEA: reality modeling, how a game tester survive in the game industry, 
#                user cases can be:
#                 >>> for a new tester comer, previous exp. future can be expected if goal is set to be a designer
#                 >>> with different perspectives ( outside views, industry veteran views, different level much the same like google earth), how to comprehend and guide?
# * 20100906, IDEA: a 3D visualization can be helpful in present the ideas and simulating a real game experience.
#
# * 20100906, IDEA: think every real world facts as a test case for underlining principles and 
# * 20100906, IDEA: [NOT-IMPLEMENTED] suggest two ways of viewing, from inside mind 'try-and-error' way and 'physical world viewport' way 


# quite abstract, don't expect to be working soon!
obj = Object.new

class << obj
  
  # try to eval() from a string.  Evolution = Trans-mutation.
  def evolve(input) 
    
      # for the moment, merely adding customized 
      # IDEA: to persistent knowledge, some complex data structure may be used, what are they?
      accumulate(input)
      more_actions(input)
  end
end


module ConnectionToTheWorld
  @connections = []  # Q: how a variable plays in a module?
  
end

class Crow
  
  def get_food
    "find food, find stick#1, find stick#2, use stick#1 to get stick#2, use stick#2 to get food."
  end
  
  
  # idea: basic nature born features like "timeout", "exhaused", ""
  
  
  def propose_a_strategy_inside_view
    # TODO: create a text-file based module and modify self.class definiation file (persist class)
  end
  
  def propose_a_strategy_outside_view(concept)
    # TODO: create a text-file based module and modify self.class definiation file (persist class)
  end
  
  private
  def create_module_file()
    
  end
  
  def load_module_file
    
  end
  
  # an object will not record all the world info, some information may contained in a related or wrapping object, much the same as a local referece instead of world reference.
  # Try to extract info( e.g. module created from the peresisted file's attributes.)
  def deduce_info() # Q: when stack to deep?
    # check attributes and methods
    
    # check  attributes and methods of related objects. 
        
    
  end
end


#def context(&block)
#  
#end
#
#context "earth"
#
#end



# understanding  "a game tester"   =>  knowledge tree  =>  implication ( minute details, skills ) based on statistic history.  

obj.describe

 
 


 


