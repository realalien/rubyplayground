#Purpose: to create different SKU builds more easily and doing checks
# Note: 
# * Because the builds for different platforms involves many setups like changing source code, recompiling
#   


require 'pp'

SKU_CODES = {
    "NA" => "BLUS-30607", # european
    "EU" => "BLES-01265", # european
    "JP" => "BLJM-60359"  # Japanese
}

COMPILE_SETTING = ["RELEASE", "SHIPPING", "DEBUG"]







# Entry point for creating a build.
# given any arugments to create a corresponding PS3 build
  
def create_ps3_build(*opt)
  
end





# for the moment, just get the information from source code that hard-coded with 
def find_changelist_built_on(project_basedir)
  target_file = "Development\\Src\\Core\\Src\\UnObjVer.cpp"
  target_pat = /#define\s+BUILT_FROM_CHANGELIST\s+(\d+)/i
  abs_path = File.join(project_basedir, target_file)
  
  if File.exists? abs_path
    File.open(abs_path, "r").each  do | line |  # quite unintuitive file read
      m = line.match target_pat
      if m and not m[1].nil?
        return m[1]
      else
        next
      end
    end
    return nil  # no line found
  else
    return nil  # file not found
  end
end

# ----- util ------

# TODO: also capture the stdout and stderr
def cmd(cmd)
  ret = system(cmd)
  return true if ret == 0
  return false  
end



# ----- backup of template file, in case it's removed------



if __FILE__ == $0
  
  
  # TODO Generated stub
  # 
  
  # debug 
  #ret = find_changelist_built_on("C:\\workspaces\\buildmachine003slave\\Alice2PeriodicBuild")
  #pp ret 
  
  
  create_ps3_build("shipping", "eu", "66586")
  
  
end