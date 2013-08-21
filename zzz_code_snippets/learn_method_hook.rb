#encoding: UTF-8

#REF:
# * http://stackoverflow.com/questions/3197635/how-do-i-run-code-before-and-after-a-method-in-a-sub-class
# * http://cheind.blogspot.com/2008/12/method-hooks-in-ruby.html
#   NOTE: some remote API should be called for every request, but some not, so it'll be helpful to hook methods in a programmatical way



class DemoClass
  def demo_method
    puts "demo_method  called!"
  end
end



module InterceptDemo
  
  # test of intercept of accessors (call inject methods after calling original)
  module ClassMethods
    private
    
    # Hook the provided instance methods so that the block 
    # is executed directly after the specified methods have 
    # been invoked.
    #
    def following(*syms, &block)
      syms.each do |sym| # For each symbol
        str_id = "__#{sym}__hooked__"
        unless private_instance_methods.include?(str_id)
          alias_method str_id, sym        # Backup original 
                                          # method
          private str_id                  # Make backup private
          define_method sym do |*args|    # Replace method
            ret = __send__ str_id, *args  # Invoke backup
            block.call(self,              # Invoke hook
              :method => sym, 
              :args => args,
              :return => ret
            )
            ret # Forward return value of method
          end
        end
      end
    end
  end
  
  
  # On inclusion, we extend the receiver by 
  # the defined class-methods. This is an ruby 
  # idiom for defining class methods within a module.
  def InterceptDemo.included(base)
    base.extend(ClassMethods)
  end
  # ------------------
end


if __FILE__ == $0
  
  # exmaple of inject methods to instance
  # a = DemoClass.new.demo_method.extend(InterceptDemo)

  # example of inject methods to class
  k = Class.new(DemoClass) do
      include InterceptDemo
  end
  
  puts k.class
  #puts k.instance_methods
  puts k.included_modules
  puts k.new.respond_to? :following
  puts k.respond_to? :following
end