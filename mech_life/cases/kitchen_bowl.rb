
case_description=<<EOD
* The keeping of the kitchen bowls is not safe as the bowls are just covered with cloth, 
  potential hazards includes dust or street pollution.
* The bowls are not upgraded unitl I attended a cooking lesson, in which the appreciation of using of specific 
  utilities are preferred.
EOD

require File.join File.dirname(__FILE__) , '../theory.rb'

class KitchenBowl
  
    def artificial_evolve
      research
      ask_for_advice
    end
end


if __FILE__ == $0
  bowl = KitchenBowl.new
  puts bowl.respond_to? :artificial_evolve
  bowl.artificial_evolve
end




