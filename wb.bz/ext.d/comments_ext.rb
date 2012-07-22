#encoding:UTF-8

require File.join(File.dirname(__FILE__),"../util.d/weibo_client.rb")
=begin    
=end
    # ----------------------------------------------------------------------
    user = $client.user_show_by_screen_name("stewartmatheson")
    #puts user.inspect
    puts user.status.class
	puts user.status.inspect
    
    comments = $client.comments(user.status.id)
        puts "----------  comments inspect: "
    puts comments.inspect
    
      puts "----------  each comment  "    
    while comments.next_page? #Loops untill end of collection
        comments.each do | comm |
            puts comm.inspect
        end
    end 
    
    puts comments.total_items
