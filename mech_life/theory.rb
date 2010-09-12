
# write experimental code or evolved code to file.
module PersistToFile
  
end

class Object
  
  def evolve
    raise NoMethodError.new("Please implement so other can reuse!")
  end
  
  def artificial_evolve
     raise NoMethodError.new("Please implement so other can reuse!")
  end
  
  def experiment_theory(theory)
    
  end
  
  def testing_against_model(model)
    
  end
  
  def boxing
    
  end

  def 
    artificial_evolve
  end
  
  def method_missing(name, *args)
    
  end
  
  def respond_to? name
    super name
  end
end



class Action
  
end

class ExperimentalAction
    
end


if __FILE__ == $0
  a = "df"
  puts a.class.ancestors
  puts a.respond_to? :artificial_evolve
  a.artificial_evolve
end