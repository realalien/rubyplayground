#encoding:UTF-8:







=begin
 
 
# last read: 2012.12.17 
# NOTE: it's a concept building  rather than code structure!
concept "bottom-up way of learning legislative system from news"


  note "very little pre-req knowledge"
  link "http://www.lawyers.org.cn/info/e1541bb9298c4a7593a55999f6ef0beb"
 
  # --- basic info retrieval 
  engine.scan_people   # retrieve organization, role, people
  engine.scan_leak ""


  # --- make context richer
  engine.find_recent_issues



  # --- compose hacking using different strategy, eg. posts on bbs, 
  engine.propose_hack_by_unleash_info "under-development of legislative channels in resorting dispute on labour issues" do

  end

  engine.propose_hack_by_unleash_info "unleash scandals" do 
      
  end
  
 engine.propose_hack_by_study "weakness in promoting, only to resolve serious dispute" do 
 
 end
 

end


=end


if  __FILE__ == $0
   
    
    
    #ner 
    
end






