require 'mechanize'

#TODO: there are much useful data(e.g. link meta data, probably for SEO, so).
def retrieve_content(url)
    begin
        m = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }
        page = m.get(url) 
    rescue => e 
        puts "[Error] retrieving #{url} "
        puts e.message
        puts e.backtrace
        # $ACCUMULATED_DELAY += 1
        #puts "[WARNING] Compulsory put programme into sleep due to page retrieval error. Back to work in #{$ACCUMULATED_DELAY} minute(s)"
        # sleep $ACCUMULATED_DELAY
        
        # just return an empty Mechanize::Page
        page = nil
    ensure
        #$TOTAL_PAGE_REQUEST += 1
        #puts page.inspect
        #puts page.content
        return page
    end
end
