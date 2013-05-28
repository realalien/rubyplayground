#encoding: UTF-8

# Purpose: find the persons of interest, find them on SNS and follow rigorously, 
# find their circles
# know what's the trend, and easier aggregating of geo, org,

require 'pp'

RAW_FILE = "./data_journalism_contributors_raw.txt"

def read_raw_file_to_array(file_path)
  f = File.readlines(file_path)  # ; puts f
  f
end

# simple and common way of retrieving person and organization from a well-formatted line text
# NOTE: if more than two elements in results, treated as organization info ( watch-out, those may be roles!)
# NOTE: rather than using key-value db, use array instead for easier/independent manipulation
def tokenize_person_comma_org(line)  
  elems = line.split(',')
  if elems.size >= 2
    return elems.map{|e| e.strip } 
  else
    return ['','']  # let caller to decide how to deal with empty info
  end
end

def aggregate_people_by_org(person_org_arrays)
  people_by_org = {}
  person_org_arrays.each do |e|
    if e.last != nil && e.last != ''
      people_by_org[e.last] ||= []
      people_by_org[e.last] << e.first
    end
  end
  people_by_org
end

if __FILE__ == $0
  
  file_path = File.join(File.dirname(__FILE__), RAW_FILE)
  # read_raw_file_to_array()
  
  # # organize line text into array structured data (wishfully a drag-n-drop UI)
  raw = read_raw_file_to_array(file_path)
  arr = raw.map{|e| tokenize_person_comma_org(e)}
  
  
  # # aggregate by organizations(last elements of person_org array)
  grp_by_org = aggregate_people_by_org(arr)
  pp grp_by_org
  orgs = grp_by_org.keys 
  pp orgs
  
  
  # # find contributors' twitters
  # # history replay
  
  
  # # find organization locations
  
  
  # # find shared datasets and tools which can be studied
  

  
  # # make an index of people's names of the book 'data journalism handbook'
  # RESEARCH: instead of using existing index engine, what is needed here is just names in the sentences
  
  
  
end