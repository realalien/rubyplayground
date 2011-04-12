# Purpose: 
#   constantly check new submitted changelist(CL) and give corresponding 
#   actions (e.g. notification, proposals of rebuilding )


require "P4"   # Q: why the eclipse can't recognize the P4 gem? 
require "pp"

require File.join(File.dirname(__FILE__),  'changelist.rb' )
require File.join(File.dirname(__FILE__),  'common/comm_util.rb' )

#  require 'fileutil'  # TODO: find candidate class for ruby 1.8.7 because no 'fileutil' exists!

# wrapping common using commands
# TODO: make it stateless, or class methods? 
#       But it's dangerous to use one client spec if there are mutlitple workspace on one machine.



$DEBUG=true   # SUG: it's not suggested to use debug, please replace with unit test cases.

$ALICE_PROJECT_SOURCE_SUFFIXES = ["CPP", "H" ]


class P4Tool
  attr_accessor :p4
  
  # TODO: add DNS to allow user input computer name rather than the service ip!
  # TODO: check all the PORT  should looks like "IP:PORT", p4.host is not effective!!
  # TODO: implement block to allow disconnect after actions rather than keep it.
  # TODO: if CPU usage is high, the command will timeout
  def initialize( host, port, client, user, passwd, *opt)
     @p4 = P4.new
     @p4.disconnect if @p4.connected?   
     @p4.host = host   # TODO: may not effective in the script, find out why!!!
     @p4.port = port
     @p4.client = client
     @p4.user = user
     @p4.password = passwd || ""
     @p4.api_level = 67 # Lock to 2010.1 format, see p4script.pdf, P47
     
     pp "@p4 is #{@p4}"
     
     begin
       @p4.connect  
     rescue  P4Exception => e
       if @p4 || @p4.connected?
         @p4.disconnect
       end
       pp e.message
       pp e.backtrace
     end

  end
  
  def close
    @p4.disconnect if @p4 and @p4.connected?
  end
 
  def get_connection
    return @p4
  end
 
end



# TODO: should be a static class!
class ChangelistTool
  
  def initialize( p4tool )             
    @p4 = p4tool.get_connection if p4tool.is_a? P4Tool
    puts @p4
  end
  
  def get_latest_changelist_number()
    chg_specs = @p4.run "changes", "-m 1 -s submitted"
    return chg_specs[0]["change"] 
  end
  
  # lists of all files and with their revision between two changelist
  def related_files_between(start_cl, end_cl)
    
  end
  
  
  # step by step, file based, database based persistence
  def save_or_update
    data_dir = "DATA"
    data_file = "latest_cl_num"
    curr_dir = File.dirname( File.expand_path(__FILE__) )
    data_store = File.join(  curr_dir ,  data_dir) 
    
    # TODO: IO Exception handling
    puts "#{data_store}"
    Dir.mkdir(data_store) if not File.directory?(data_store)
    file = File.join(data_store, data_file )
    # File.delete(file)  if File.exists?(file)
    
    f = File.new(file, "w+")  if not File.exists?(file)
    f.close
    
    max = read()
    if get_latest_changelist_number().to_i > max
      f = File.open(file, "w+")
      f.puts "#{get_latest_changelist_number()}"
      f.close  
    end
    
  end
    
  def read
      data_dir = "DATA"
      data_file = "latest_cl_num"
      curr_dir = File.dirname( File.expand_path(__FILE__) )
      data_store = File.join(  curr_dir ,  data_dir) 
      file = File.join(data_store, data_file )
      arr = IO.readlines(file)
      return arr[0].strip!.to_i || 0
      
  end
  
  
  # Suggest entry point for any user input, in Perforce changelist context. 
  # parameter of the method can be 
  # a changelist number, a range of changelist, a date in which changelists fall in,
  # perforce user(s),  
  # *
  def suggest(anything)
     if anything.is_a? Fixnum
        suggest_using_changelists anything       
     end
    
  end
  
  
  # hopefully the client code can look like below, 
  # and return true/false for program use and feedback to human.
=begin
  suggest_using_changelists(1111) do
    # add points of interests to allow give feedback e.g.
    need_recompile?
    need_recook?

    produce_action_plan
  end
    
  # IDEA: should it be later binding? or just give a default list of 
=end  
  
  # Q: how to give reports as feedback?
  # IDEA: it looks unnecessary to test an old changelist with a new changelist, so the method
  #     implemented now is assumed that a new cl will be introduced and all suggestions are based
  #     on that. Otherwise, context info. like HEAD revision of the workspace should also be ack.
  def suggest_using_changelists(cl_number, &poi)
    chg = chg_spec(cl_number)
    need_recompile? chg
    need_recook? chg
#    if not block_given?
#       # list all the default check for a changelist
#       
#    else
#       yield
#    end
   
  end
  
  
  def need_recompile? chg 
    # should have some knowledge about existing binaries time stamp and if new changes actually applied.
    # TODO: handling the test of existing head revision and changelist need to be introduced.
    if chg.has_source_code?($ALICE_PROJECT_SOURCE_SUFFIXES)
      return true
    end
    return false
  end
  
  
  def need_recook? chg
    if chg.has_source_code?($ALICE_PROJECT_SOURCE_SUFFIXES)
      return true
    end
    return false
  end
  
  # watch out the file being checkout, it will cause problem
  # (unable to get the file) for nightly build workspace if that file is 'opened'.
  def monitor_local_open_files
    
  end
  
  
  
  
    
end








#  memory of history 


if __FILE__ == $0
  p4t = P4Tool.new("192.168.6.11",   # attention: it looks like the 
                    "192.168.6.11:1666", 
                    "Admin_spicyfile_1666_buildmachine003slave",
                    "Admin", 
                    nil)
                    
  lstn = ChangelistTool.new(p4t)
  # pp lstn.get_latest_changelist_number
  # lstn.save_or_update
  # puts lstn.read
  
  
  # test run for give changelist advice   # program by intention   
  # TODO: yak-shave to put a dict into changelist 
  ###lstn.suggest("1111")  #  number in context is 
  
  
  cl = Changelist.new("1111", p4t.get_connection)
  assert("changelist 1111 doesn't contains .cpp or .h") do
    cl.has_source_code?(".cpp", ".h")  == false
  end
  
  c2 = Changelist.new("1117", p4t.get_connection)
  assert  { c2.has_source_code?(".h", ".cpp")  == true  } 
  
  # test if vararg has a parameter of class Array  
  # SUG: this test shows that the assertion text not shows the intention of the test and specific scenario for testing
  assert("changelist 1111 doesn't contains .cpp or .h even specify an array as source code criteria") do
    cl.has_source_code?($ALICE_PROJECT_SOURCE_SUFFIXES)  == false
  end
  
  
  c3 =  Changelist.new("1117", p4t.get_connection)
  assert("changelist 1117 is submitted! ")  {c3.is_submitted?  == true }
  
  
end