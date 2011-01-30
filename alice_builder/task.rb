
require "observer"

# TODO, should have knowledge of color for legend
class TaskStatus
    OK          = 1
    FAILED      = 2
    TAINTED     = 3
    RUNNING     = 4
    UNAVAIL     = 5
end


# IDEA: if possible, the state machine can be used to allow actions take place during the status change, 
#      it's very important to let known what to do if something goes unexpected.
class Task
   
    include Observable 
    
    def initialize(name)
        @name = name
        @status = nil
    end
    
    def plan(&how_to)
        if block_given?
            @how_to = how_to
        end
    end
    
    def run
        # pre tasks
        
        # post tasks
        
        if @how_to
            begin
                @status = TaskStatus::RUNNING
                @how_to.call
            rescue             Exception => e 
                puts "[ERROR] #{@name} FAILED. " # TODO: logging
                puts e.message   
                puts e.backtrace.inspect
                puts "---------------------"
                @status = TaskStatus::FAILED
                return 
            end
            @status = TaskStatus::OK
        end
        # TODO: how to handle deferred/delayed/async result
        # if task ends successfuly        
    end
    
    # the 
    def evaluate_result
        return @status
    end
    
    # debug use, not really for 
    def set_status(status)
        if status.is_a? TaskStatus
            @status = status    
        end
        @status = TaskStatus::UNAVAIL
    end
end



# I think it should be part of task itself, or use pattern generator to create a list like object in order 
# to give less coding.
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