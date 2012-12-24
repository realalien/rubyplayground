
# test out grabbing js based page text from 
# http://www.labour-daily.cn/web/NewLabourElectronic/newpdf/PdfNews.aspx


require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.labour-daily.cn/web/NewLabourElectronic/newpdf/PdfNews.aspx"


def get_results
     visit('/')
     # fill_in "q", :with => "Capybara"
     # click_button "Google Search"
     #click_link ""
      all(:xpath, "//*[substring(@id,1,8)='dgLayOut']").each { |a| puts a[:href] }
end



if __FILE__ == $0
  get_result
end
