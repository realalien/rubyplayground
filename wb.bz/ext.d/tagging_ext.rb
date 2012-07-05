#encoding:UTF-8

require File.join(File.dirname(__FILE__),"demo.rb")


# EXP: persistent, different tagging(e.g. job, role)

# TODO: add a log when created/updated in db

# NOTE: this class stands for the weibo accounts those have been saved to local database
class WeiboUser
    include Mongoid::Document
    

    include Mongoid::Timestamps::Updated  # TODO: it actually mingles with the weibo's data. How to change default column updated_at
    
    embeds_many :tag_categories
end


class WeiboUserManager
   
    # TODO: actually a single tagging process, we query the local db multiple times, tune it please!
    # TODO: see this class can also do some sanity checking.
    def self.tag_user_with_category_and_tags(user, category_name, tags, *opt)
        begin
            target_user = WeiboUser.find(:id => user.id)
            puts  target_user.nil? ? "YES " : "NO"
            puts target_user.inspect
            
            # no exception thrown, should find one 
            # see if has job category
            puts "[INFO] User is already in the database local db"
            cate = target_user.tag_categories.find(:name => category_name)
            
            if cate.nil?
                cate = TagCategory.new( :name => category_name)
                target_user.tag_categories << cate
            end
            
            
            tags.each do | t | 
                tag = cate.tag_infos.where( :name => t)  # TODO: bugs here!
                if tag.nil?
                    cate.tag_infos << tag
                else
                    puts "[INFO] #{t.name} has been added already!"
                end
            end
          
            target_user.save!
        rescue Mongoid::Errors::DocumentNotFound
            puts "[INFO] Going to new and persistent user to local db"
            remote_user = $client.user_show user.id  # TODO: seem already a valid weibo user here.
            target_user = WeiboUser.new( JSON.parse(remote_user.data.to_json) )
            
            puts target_user.inspect
            # add one TagCategory
            category = TagCategory.new( :name => category_name)                
            # add one TagInfo
            
            tags.flatten.each do | t |
                tag = TagInfo.new(:name => t, :source => opt["source"] || "not specified" , :is_manual => (opt["is_manual"] == true ? true: false ) )        
                # assembly
                category.tag_infos << tag
            end
            
            puts category.inspect
            target_user.tag_categories << category
            target_user.save!
            puts target_user.inspect
        end 
    end
end

class TagCategory
    include Mongoid::Document
    
    field :name, type: String
    # field :tags, type: Array   # use embeded document
    
    index({ name: 1 }, { unique: true, name: "tag_category_name_uniq_idx" })
    
    embeds_many :tag_infos
    embedded_in :weibo_user
end
 

class TagInfo
    include Mongoid::Document
    
    
    field :source, type: String   # where the data is retrieved
    field :is_manual, type:Boolean 
    include Mongoid::Timestamps::Updated
    
    embedded_in :tag_category
end


class Organization
    include Mongoid::Document 
    
    
    field :full_name, type: String
    field :short_name, type:String
    
    def self.is_public_sector
        return false ; #true if 
    end

    
    
end

# workload here!


# For now, it's a CLI processor
class ManualTagger
    
    @@allowed_tag_categories = ["jobs", "pois"]
    @@repo = {}
    @@user = ""
    
    def self.ask_for_user_to_be_tagged
        print "Please input the target user's weibo id or screen_name(enter to stop): "
        name_or_id = $stdin.gets.chomp

        # suppose id first, then screen id
        begin
            user = $client.user_show name_or_id
            puts user.inspect
            
            @@user = user  # tempory keeping
            @@repo[user.id] = {} 
            self.ask_for_tag_category
            #return user
        rescue Grizzly::Errors::WeiboAPI  # not found, 20003
            begin 
                user = $client.user_show_by_screen_name name_or_id
                puts user.inspect
    
                @@user_id = user.id 
                @@repo[user.id] = {}
                self.ask_for_tag_category
                #return user
            rescue Grizzly::Errors::WeiboAPI
                return  # more than we can/will handle
            end
        ensure 
            #return
        end
    end
    
    def self.ask_for_tag_category
        print "Please input a tag category(enter to stop): "
        
        # keep asking for a non empty string
        while ((name =  $stdin.gets.chomp).empty? or  not @@allowed_tag_categories.include?(name) )
            puts "'#{name}' is either empty or not in the categories allowed to be added! Input again:"
            # TODO: since it's a manual process, we should require the input to be well formatted and reinput for confirmation
        end

        @@repo[@@user.id]["tag_category"] = name
        puts @@repo.inspect

        self.ask_for_tag_info
    end


    def self.ask_for_tag_info
        tags = []
        print "Please input tags(separated by blankspaces, enter to stop): "
        
        until (name =  $stdin.gets.chomp).empty?
            # parse the input
            tags << name.split(/\s+/)
        end

        puts tags
        # actually we can only process on tag_category at a time, no need for '["tag_category"]["tags"]'
        @@repo[@@user.id]["tags"] = tags

        puts @@repo


        print "Finally, where do you get this info(enter to stop): "
        @@repo[@@user.id]["source"] =  $stdin.gets.chomp

        self.manual_tagging(@@user,@@repo[@@user.id]["tag_category"],@@repo[@@user.id]["tags"])
    end

    
    def self.manual_tagging(user, tag_cate, tags)
        puts @@repo

        # persist
        WeiboUserManager.tag_user_with_category_and_tags(user, tag_cate, tags, { :is_manual => true, :source =>  @@repo[@@user.id]["source"]})


        # clean
        @@repo.delete @@user.id
    end
end






# IDEA: because there are many ways of categorizing data, think the tagging process of 'text' way of categorying data. 
#    (AFM: research paper to support the tagging behavior and practice".  
#    Besides the tagging, another way of categorizing data is to have some kind of manager or artificial library do the 
#    booking keeping of all data(it goods at aggregating data, but may not be versatile to deal with changes).
class AutoTaggingBot
    JOB_CATEGORY = "jobs"
    
    # IDEA: actually user's data or user's status update can be 
    # for simple demo, we only check the description in user's data.
    def self.tag_user_jobs_with_jobname(user, jobname)
        if user.description.include? "#{jobname}"
            puts user.screen_name
    
            
            
            puts "[INFO] Tagging job #{jobname} in th for user '#{user.screen_name}' (id:#{user.id})"
            $COUNT += 1
        else
            puts "[INFO] Not found job #{jobname} in the description of user '#{user.screen_name}' (id:#{user.id})"
        end
    end
end


class AutoTellingBot
    def self.find_weibousers_with_jobname(jobname)
        users = []
        query = WeiboUser.where( "tag_categories.tag_infos.name" => jobname)
        query.each do | u |
            users << u
        end
        puts users.inspect
    end
end

    
    # ------------------------------------------    
    # EXP: Tagging Test
    #ManualTagger.ask_for_user_to_be_tagged

# ------------------------------------------
=begin    
    #user = $client.user_show_by_screen_name("realalien")
    #find_bifriends_geo_distribution(user.id)
    
    user = $client.user_show_by_screen_name("csdn")
    puts user.description
    users = $client.friends(user.id)
    
    jobname = "CEO"
    
    #AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
    #while users.next_page? #Loops untill end of collection
    #    users.each do | user|
    #       AutoTaggingBot.tag_user_jobs_with_jobname(user, jobname)
    #    end
    #end
    
    AutoTellingBot.find_weibousers_with_jobname "CEO"
    
    puts "Total number of people whose jobname contains #{jobname} and in friendship with #{user.name}(id: #{user.id})"
    puts $COUNT
=end
 
    # ------------------------------------------ Taggable persistence
=begin    
    # persistent test
    user = $client.user_show_by_screen_name("realalien")
    user_data =  user.data.to_json
    puts "---------------"
    puts user_data
    WeiboUser.create( JSON.parse(user_data) )

    u1 = WeiboUser.find user.id
    puts "--------------- u1"
    puts u1
    
    puts "ready to tagg it to the user:" + user.screen_name
    t = Taggable.new( :tag_category_name => "job", :tags => ["programmer", "project maintainer" ] )
    u1.taggables << t 
    u1.save!
=end
    
