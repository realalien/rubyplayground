#encoding: UTF-8


# Purpose: keep a weekly log of how many communities(nodup) collected by data crawling, supposingly grouped by district in Shanghai.


require File.join(File.dirname(__FILE__), 'const.rb')
require File.join(File.dirname(__FILE__), 'models.rb')
require File.join(File.dirname(__FILE__), 'conn_mongo.rb')

$ACHIEVEMENT_PROGRESS_FILE = "achievement_progress.txt"




# collect communities from ddmap




# --------------------------------------------------------------------------------

# r/w a file
def record_today_achievement
  unless File.exist? $ACHIEVEMENT_PROGRESS_FILE
    File.new($ACHIEVEMENT_PROGRESS_FILE, "w+") {}
  end
  
  File.open($ACHIEVEMENT_PROGRESS_FILE, "a+") do |f|
    # header
    line = "-------- #{Time.now.strftime('%Y-%m-%d %A, %H:%M:%S')} --------"
    f.puts(line)
    
    # total records
    line = "Total communities collected:  #{Community.count}, following are aggregated by district name"
    f.puts(line)
    
    # find existing area levels
    $SH_DISTRICTS.each do | district |
        comms_by_city_district = Community.of_city_and_district($SH_CITY, district)
        line = "--- District: #{district} (#{comms_by_city_district.count})"
        f.puts(line)
        names = []
        comms_by_city_district.each do | comm|
            names << comm.name
        end
        if names.size > 0
            line = "#{names.join(',')}"
            f.puts(line)
        end
    end
      
      
    # grouped data by levels
    # tail
    line = "---------------------------------"
    f.puts(line)
    line = "\n"
    f.puts(line)
  end
  
  
  
  

  
  
  
end





if __FILE__ == $0
  
    
  

  # statistics
  record_today_achievement
    
end

