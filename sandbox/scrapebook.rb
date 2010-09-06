


#  ---------------------------------------
#module Mod
#  def mod_method
#    puts "mod_method from Mod"    
#  end
#end  
#
#def test_use_mod_method_in_method_def
#  include Mod
#  mod_method
#end
#
#test_use_mod_method_in_method_def


#  ---------------------------------------


module Mod
  def mod_method
    puts "mod_method from Mod"    
  end
end  

def test_write_module_def_to_file(filename)
  include Mod
  
  #Q: how can I dynamically modify the include MO
  #IDEA: need extract methods to find candidates/potential useful methods from inputed keyword.
end

test_write_module_def_to_file