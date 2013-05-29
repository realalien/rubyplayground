#encoding: UTF-8

# Purpose: to filter data of a news articles, some info can be classified in a category, think
#  it like a grid box with each cave for small electronic components.




class Grid
  attr_accessor :name
  attr_accessor :rows, :cols 
end

# example of matrix alike info grouping
g1 = Grid.new
g1.name =  ""
g1.rows = ['','','']
g1.cols = ['','','']


# example of cols which are independent of (header) rows 
g2 = Grid.new
g2.name = ""
g2.rows = ["civic crime", ""]  #  main classification
g2.cols = [ [''] ]  # subclass of 

 
# NOTE: more like a blade into a box
class Layer
  attr_accessor :name
end

l1 = Layer.new
l1.name = "crime layer 2013.5.29"

#l2 = Layer.new
#l2.name = "new crime layer deviced"

l3 = Layer.new
l3.name = "geo map layer 2013.5.29"


l1.inaugrate(g2)
res = l1.sieve() # news of specific day 





