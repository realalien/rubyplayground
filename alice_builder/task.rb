
require "observer"

class Task
    
    include Observable 
    
    def initialize(name)
        @name = name
        
        
    end
    
    def plan(&how_to)
        if block_given?
            @how_to = how_to
        end
    end
    
    def run
        if @how_to
            @how_to.call
        end
        # TODO: how to handle deferred/delayed/async result
        # if task ends successfuly        
        
    end
end


class TaskList
    
   
    attr_accessor :tasks
    
    def initialize
        @tasks = []
    end
    
    def <<(task)
        @tasks << task    
    end
    
    def run
        @tasks.each do | t| 
            t.run
        end
    end
    
end


if __FILE__ == $0
    t1 = Task.new "task test"
    t1.plan do 
        puts "starting..."
        puts "end"
    end
    
    tl = TaskList.new 
    tl << t1
    
    tl.run
    
    
    
    
end