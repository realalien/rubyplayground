

require "test/unit"


module Checkings
  
  def check_method_missing_usage
    # static checking or dynamic checking? 
    has_defined_response_to_if_overriding_method_missing?
    
  end
  
  def has_defined_response_to_if_overriding_method_missing?
      #can I peek into the source code? it can't, then how?
      
  end
  
      
  

end

class TestObject < Test::Unit::TestCase
  
  class A
    def method_missing(name, *args)
      
    end
    
    def respond_to?
      
      
    end
    
  end
  
  def test_check_method_missing_usage
    
  end
end


class A 
  
end

puts "A.class\t=>\t\t#{A.class}"
puts "A.superclass\t=>\t\t#{A.superclass}"
puts "A.respond_to?(:method_missing)\t=>\t\t#{A.respond_to?(:method_missing)}"
puts "A.respond_to?(:respond_to?)\t=>\t\t#{A.respond_to?(:respond_to?)}"
# 
puts "a = A.new " ; a = A.new
puts "a.respond_to?(:method_missing)\t=>\t\t#{a.respond_to?(:method_missing)}"
puts "a.respond_to?(:respond_to?)\t=>\t\t#{a.respond_to?(:respond_to?)}"
#puts "a.unknown_method\t=>\t\t#{a.unknown_method}"


class A
  def method_missing(name, *args)
    puts "not defined! "
  end
end

puts "def method_missing(name, *args)...." ; a = A.new
puts "a.respond_to?(:method_missing)\t=>\t\t#{a.respond_to?(:method_missing)}"
puts "a.respond_to?(:respond_to?)\t=>\t\t#{a.respond_to?(:respond_to?)}"
puts "a.unknown_method\t=>\t\t#{a.unknown_method}"
