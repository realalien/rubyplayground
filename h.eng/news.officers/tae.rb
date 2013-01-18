#encoding: UTF-8

def unrepeat(str)
  n = str.size

  newstr = str
  n.times do |i|
     newstr = newstr[-1] + newstr[0..-2]
     if newstr == str
        return i + 1
     end
  end
end


if __FILE__ == $0

	

end
