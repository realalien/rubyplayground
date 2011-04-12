


# Simple assert  
# see: http://snippets.dzone.com/posts/show/925
def assert(*msg)
  raise "[ Assertion Failed ]\n " + "#{msg}" unless yield if $DEBUG
end


# Convert a Ruby hash into a class object
#  http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/comment-page-1/
# TODO: or try this one! 
# https://github.com/intridea/hashie/blob/master/lib/hashie/mash.rb
class Hashit
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    end
  end

  def save
    hash_to_return = {}
    self.instance_variables.each do |var|
      hash_to_return[var.gsub("@","")] = self.instance_variable_get(var)
    end
    return hash_to_return
  end
end







if __FILE__ == $0
  # TODO Generated stub
end