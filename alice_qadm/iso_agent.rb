# status of each builds
# Progress  => test the backend function
# IDEA: try not abstract with too many concepts, to allowing easy voice-based refactoring and graphic manipulations



 
require 'rubygems'
require 'mongo'
#require 'unittest'
 

# agent provide services for validate a build and doing the book keeping
class BuildCheckAgent
 
  DB_NAME = "Alice2"
  DB_COLL_NAME = "builds"
 
  # one file is unencripted, abeforehand check, see also #check_iso_fingerprinted
  def check_gp3_file_valid
    def fingerprinted_file_unencrypted?
 
    end
 
    def alice1_presents?
    end
 
    def ps3cmd_checked_ok?
 
    end
   
    return fingerprinted_file_unencrypted?
            & alice1_presents?
            & ps3cmd_checked_ok?
  end
 
  def check_iso_fingerprinted(filename, search_string="a37dd45", offset=12)
    puts "check fingerprinted"
   
    # use "decrypt.exe" tool provided by EA.com
    cmd = "C:/Users/zhujiacheng/Desktop/XP_RightClickToFingerprint/XP_RightClickToFingerprint/decrypt.exe"
    opts = [ filename, search_string, offset].join(" ")
    result = system("#{cmd} #{opts}")
    #puts result
    return true if result="true"
    return false
 
  end
 
  def check_iso_existence
    puts "check iso existance"
  end
 
 
=begin
  -------------   util methods --------------
=end
  # to avoid rechecking the ok ones, within a certain time like a day, must the same file with uuid
  def read_last_check_result
  end
 
  def check_all
    #TODO: limit the method collection that belongs to self.class rather than inherited.
    puts self.methods.find_all { |m| m =~/^check_/ }.to_a.inspect
    # TODO: better to use a general methods to get the method name, otherwise refactor not nice
    chk_meds = self.methods.find_all { |m| m =~/^check_/ }.to_a
    chk_meds.each do | m|
      self.send m  if m != "check_all"
    end   
 
  end
 
 
end
 
# help class to create specific builds by following the specified steps, also help to do some checking ahead and after.
class BuildCreatorRegulator
  
  DB_NAME = "builds"
	DB_COLL = "rules"

  # because different tasks have different steps of process, which I think it's best to have methods pointers to refer
  def initialize(build_task)
    @name = build_task
    # read the database to retrieve previous setting, Q: will the data record has the sense of history, otherwise it's better to create a SCM to track A:
		@pre_checks = []
		@post_checks = []
		@rules = []
  end

  def pre check_task
		@pre_checks << check_task
	end

	def post check_task
		@post_tasks << check_task
	end

	# really make the builds, allowing add steps 
	# TODO: must create linkedlist alike data structure to allow sequenced steps.
	def process_rule task=nil
    @rule << task
	end


	def create
  	puts "a build is created! Though artificially now :) "  
	end
	
	##  
  # create a similar set of rule based on existing one. scenario, ps3_jpn_sku is more strict rule than ps3 builds
	def copy_instance
	end

	def save_or_update
    
	end


end
 
 
if __FILE__ == $0
 
  # bca = BuildCheckAgent.new
  # bca.check_all
  # bca.check_iso_fingerprinted("D:\\Downloads\\Alice2_X360_2011-03-21_60446_RELEASE.iso")
  
  ps3_jpn_sku = BuildCreatorRegulator.new "ps3_jpn_sku"
	# just create a step of rules, maybe it should read from/write to a configuration files
  ps3_jpn_sku.pre "check_isjpnsku_true_effective" "check_other_configure_default"
  ps3_jpn_sku.post "check_fingerprinted" "check_normal_size"
  # ps3_jpn_sku.process_rule "blah"

	ps3_jpn_sku.create()
	# IDEA:  ps3_jpn_sku.create( trial=True)  # do not really generate a build, run pre_checks only






  







	


end
 
