#Purpose: to create different SKU builds more easily and doing checks
# Note: 
# * Because the builds for different platforms involves many setups like changing source code, recompiling
# * Before any GUI tool is implemented, try to modulate the methods   
# * concept of transaction, each build shall be created clean, can't be tainted by other process.

require 'pp'
require 'fileutils'

$SCRIPTING_MODE = :EXPERIMENT 
SKU_CODES = {
    "NA" => "BLUS-30607", # european
    "EU" => "BLES-01265", # european
    "JP" => "BLJM-60359"  # Japanese
}

COMPILE_SETTING = ["RELEASE", "SHIPPING", "DEBUG"]


# 

# --------- general asks -----------
# ESP. try to make the methods reusable, so later can be graphical.


# SUG: better if more general command wrapper
class UEWorkspaceTool


def initialize(basedir)
  @@project_basedir = basedir

  if basedir.nil? or not File.exists? basedir
    throw "[ERROR] Must give a directory as project base directory!"
  end  

  return self # to allow one line init and execution
end

# --- daily task
def prepare_raw_data(game="Alice", platform="PS3", base_folder=nil, dest="d:\\", build_mode="", *lang_ext )
  # sanity check
  if not ["RELEASE", "SHIPPING", ""].include? build_mode
    build_mode = ""   # SUG: use online auto spellcheck, or at least check the build can be up-and-running
  end

  if base_folder.nil?
    base_folder = "#{game}2_#{platform}_#{Time.now.strftime("%Y-%m-%d")}_#{find_changelist_built_on(@@project_basedir)}_#{build_mode}"
  end

  comm = []
  comm << "Binaries\\CookerSync.exe"
  comm << "#{game}" 
  comm << "-p #{platform}"
  lang_ext.each {|l| comm << "-r #{l}" }
  comm << "-b #{base_folder}"
  
  comm << "#{dest}"
  cmd(comm)
end




# Entry point for creating a build.
# given any arugments to create a corresponding PS3 build
  
def create_ps3_build(*opt)
  
end


end
# end of class UEWorkspaceTool
# ---------------------------------------------------------------


# ------  facilitate ------


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
    return nil  # no such line found
  else
    return nil  # file not found
  end
end

# ----- util ------

# TODO: also capture the stdout and stderr
def cmd(cmd)
  if cmd.is_a? Array
    cmd = cmd.join(" ")
  end

  if $SCRIPTING_MODE == :PRODUCTION
    ret = system(cmd)
  else
    puts "[INFO] #{cmd}"
  end
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
  
  
  # unfin
  #create_ps3_build("shipping", "eu", "66586")
  
  
  #
  # mock a file
  d = "/home/realalien/sandbox/ueproject/Development/Src/Core/Src/"
  FileUtils.mkdir_p d
  f = File.new File.join(d, "UnObjVer.cpp"), "w+"
  f.write "#define BUILT_FROM_CHANGELIST  9999"
  f.close
  a = UEWorkspaceTool.new("/home/realalien/sandbox/ueproject/")
  
  a.prepare_raw_data(game="Alice", platform="PS3", base_folder=nil, dest="d:\\",  build_mode="", "INT", "DEU", "ESN", "FRA", "ITA", "JPN" )

  a.prepare_raw_data(game="Alice", platform="PC", base_folder=nil, dest="d:\\",  build_mode="",      "INT", "DEU", "ESN", "FRA", "ITA", "JPN" )


 #  a.prepare_raw_data(game="Alice", platform="XBox360", base_folder=nil, dest="d:\\",  build_mode="",      "INT", "DEU", "ESN", "FRA", "ITA", "JPN" )
  


end
