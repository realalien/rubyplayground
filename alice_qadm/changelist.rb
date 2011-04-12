# we just create a skeleton, for easy data accessing, rather than hard-code every 
# instance shall be created from a hash

# ATTENTION: 
# * All feedbacks should based on submitted changeslist, not pending one which may never check in.

# TO_STUDY:
# * the fetch_<spec> actually  has run a command with '-o' output. 
class Changelist
  
  KNOWN_ATTRS = ["rev", "action", "time", "type", "client", "desc", "depotFile", "status", "user"]
   
  def initialize id, p4_conn
    @id = id
    @p4 = p4_conn   # get tar
  end
  
  
  # TODO: should handle p4 exception in other class
  def is_submitted?
    begin
      data = @p4.fetch_change("-o", @id)
    rescue
    end
    
    return false if data.nil?  # Q: is it safe to remove this clause?
    return true if data["Status"] == "submitted"
    return false
  end
  
  
  def has_source_code?(*file_suffixes)
    file_suffixes = file_suffixes.flatten  # to allow an array 
    suffixes = []
    # sanity check
    file_suffixes.each do | f |
       f.gsub!(".", "")  # remove dot if user specified
       f.upcase!         # avoid case sensitive problems
       suffixes  << f 
    end
    pp  suffixes 
    
    # load files infor from changelist number
    begin
        data = @p4.run("describe", @id )
    rescue
    
    end
    
    #pp data
    #pp data.class
    
    # TODO: should auto boxing the hash
    dict = data[0] if not data.nil?
    return false if data.nil?
    
    dict["depotFile"].each do | file | 
      file_ext = File.extname(file)
      file_ext.gsub!(".", "") if file_ext != "" or not file_ext.nil? # remove dot if user specified
      file_ext.upcase!  if file_ext != "" or not file_ext.nil?       # avoid case sensitive problems
      
      if suffixes.include? file_ext
        return true
      else
        next
      end
    end
    return false # no file found 
  end

  
  # diagram to help to give best time for create a build based on the frequency of changes made.
  def generate_daytime_distribution 
      
  end
  
end