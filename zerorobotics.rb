

{ link => "http://zerorobotics.mit.edu/" ,
:link_more => "http://www.nasa.gov/mission_pages/station/science/experiments/SPHERES-Zero-Robotics.html",
:activity => "High School Competition for Future Engineers: Teams to Design \
Software for Small Satellites on the International Space Station. The competition \
centers on the Synchronized Position Hold, Engage, Reorient, Experimental \
Satellites, or SPHERES. "
}

{ :project => "SPHERES",
  :goal => "The goal is to build critical engineering skills for students, such as\
  problem solving, design thought process, operations training, and team work.\
  Ultimately we hope to inspire future scientists and engineers so that they will\
  view working in space as 'normal', and will grow up pushing the limits of \
  engineering and space exploration."

}

# ATTENTION, 
# the ruby code is not syntax-corrected, just a concept.

module GoalBasedPerspective
  
  def act_as_goal
    puts "going to create goals"
  end

end


# Q: I really don't like the name of the class, 
#    is there any possiblities to change the name?
module UtilityBasePerspective
  def act_as_benchmark_creteria
  end
  
  def how_to_guide
  end
  
  def integrate_other_utilities
  end
  
end

module KnowledgeConceptPerspecitive
  def load_references
  end


  def bridge_other_sciences
  end  
end




# classes that can be incorporated with above modules 

class Skill
  include GoalBasedPerspective
end


class ProblemSolving < Skill
  include GoalBasedPerspective  # Q: why such code not functions?
end

class DesignThoughtProcess

end

class OperationsTraining

end

class Teamwork 

end


class PresentationSkills

end 


a = ProblemSolving.create_goal

