#encoding:UTF-8

require 'nokogiri'
require 'open-uri'
require 'Mechanize'


$no_data_univs = []

def get_raw_toc
  xpath = '//*[@id="paste_code"]'
  toc="http://pastebin.com/AQWhu8Ek"
  
  doc = Nokogiri::HTML(open(toc))
  node = doc.at_xpath(xpath)
  raw = node.content

  #puts raw

  # write to file
  Dir.mkdir("./page_data") unless File.directory? "./page_data"
  File.open("/page_data/toc", "w+" ) do |f|
    f.puts(raw)
  end
end



# save the webpage with data to file
def dump_web_pages_of_univ(filename,content)
  File.open("./page_data/#{filename}", "w+" ) do |f|
    f.puts(content)
  end

  # keep a checklist of downloaded/missing one
     

end


# NOTE: at the moment of writing this script, only 'http://pastebin.com/' links has valid pages, other mirrors has been removed!
def collect_raw_univ_pages(mirrors, univ_name)
  if mirrors.is_a? Array
    mirrors.each do | url|
      if url =~ /http:\/\/pastesite.com\// # use pastesite only 
         begin
           mc = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
           page = mc.get(url)
         rescue => e
           $no_data_univs << univ_name
           puts "[Error] retrieving #{url} "; puts e.message; puts e.backtrace
           page = nil
         ensure
           #puts page.inspect ; #puts page.content
           #return page
         end 
         dump_web_pages_of_univ("#{univ_name.gsub(/\s+/, '')}", page.body ) if page
      end
    end
  end
  
end


# line parsing
def parse_univ_listing(content)
  content.each_line do |l|
    if l =~ /Mirror1/  # weak assumption on data listing format
      elems = l.split("-")
  
      if elems.size == 2
        univ_name = elems[0].strip 
        mirrors = elems[1].strip.split(/\s+/).keep_if {|e| e =~ /https:\/\/|http:\/\// }
        #puts "univ: #{univ_name} has #{mirrors.size} mirros of data"
        #puts "#{mirrors.join(',')}"
        collect_raw_univ_pages(mirrors, univ_name)   
      else # for 'Other universities" 
        univ_name = "Other Universities" 
        mirrors = l.strip.split(/\s+/).keep_if {|e| e =~ /https:\/\/|http:\/\// }
        #puts "univ: #{univ_name} has #{mirrors.size} mirros of data"
        #puts "#{mirrors.join(',')}"
        collect_raw_univ_pages(mirrors, univ_name)   
      end
        
    end
  end  
end



if __FILE__ == $0
  
  Dir.mkdir("./page_data") unless File.directory? "./page_data"

  # --------  1st iter, get raw page data
  #raw_toc = get_raw_toc
  #parse_univ_listing(raw_toc) 

  #puts "[WARNING] Following universities has no pastesite pages, therefore can't retrieve those data pages, please inspect for other solutions!"
  #puts "#{$no_data_univs.join(',')}"


  # --------- 2nd iter, find empty data 
  empty_data = []
  files = Dir.glob("./page_data/*")
  files.each do |f|
   # puts "#{File.basename(f)} :  #{'%.4f' % (File.size(f).to_f / 2**20)} MB"  
    empty_data << File.basename(f)  if (File.size(f).to_f / 2**20) < 0.004
  end

  puts "Total empty univ data files #{empty_data.size} among #{files.size} "
  puts "#{empty_data.sort.join(', ')}"




end
