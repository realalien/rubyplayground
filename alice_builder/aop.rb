
# experimental, cross-cutting AOP style 
# source : http://stackoverflow.com/questions/2135874/cross-cutting-logging-in-ruby
class Module
    
    include CurrentMethodName
    
    def self.define_aspect(aspect_name, &definition)
        define_method(:"add_#{aspect_name}") do |*method_names|
            method_names.each do |method_name|
                original_method = instance_method(method_name)
                define_method(method_name, &(definition[method_name, original_method]))
            end
        end
    end
    # make an add_logging method
    define_aspect :logging do |method_name, original_method|
        lambda do |*args, &blk|
            puts "Logging #{method_name}"
            original_method.bind(self).call(*args, &blk)
        end
    end
    
    # make an add_counting method
    global_counter = 0
    define_aspect :counting do |method_name, original_method|
        local_counter = 0
        lambda do |*args, &blk|
            global_counter += 1
            local_counter += 1
            puts "Counters: global@#{global_counter}, local@#{local_counter}"
            original_method.bind(self).call(*args, &blk)
        end
    end
    
    # add exception hanlding for each functions to get what knowledge
    define_aspect :exception_handling do | method_name, original_method |
        lambda do |*args, &blk|
            begin 
                original_method.bind(self).call(*args, &blk)     
            rescue Exception => detail 
                puts "*" * 72
                puts ">>>>>>>>>      " + method_name.to_s + "    <<<<<<<<"
                puts detail.message
                puts "*" * 72
            end
        end
    end
    
end