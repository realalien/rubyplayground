=begin    
    # ----------------------------------------------------------------------
    user = $client.user_show_by_screen_name("何帆")
    #puts user.inspect
    puts user.status.class
    
    comments = $client.comments(user.status.id)
    puts comments.inspect
    
    while comments.next_page? #Loops untill end of collection
        comments.each do | comm |
            puts comm.inspect
        end
    end 
    
    puts comments.total_items
