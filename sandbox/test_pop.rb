

require 'mechanize'


url = "http://www.xiaomishu.com/shop/D36D19J42560/dish/611570/#menu"

100.times do 

  m = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  page = m.get(url)

end

#http://www.xiaomishu.com/shop/D36D19J42560/dish/611570/#menu
