# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_ksiega_session_id'
  
  def back
    popBackLink
    backLink = popBackLink
    
    #dodaje informacje że to jest wsteczny link
    if backLink =~ /\?+/
      backLink = backLink + "&"
    else
      backLink = backLink + "?"
    end
    backLink = backLink + "backLink=true"
    
    redirect_to backLink
  end
  
  protected
    #metody do obsługi linków wstecznych  
    def newBackLinks
      session[:back_links_stack] = Array.new
    end
    def getBackLinks
      session[:back_links_stack]
    end
    def setBackLink
      getBackLinks().push(request.env['REQUEST_URI'])
    end
    def popBackLink
      getBackLinks().pop
    end
  
    #formatowanie danych
    def format_db_date(d)
         if !d
            return ''  
        end
        
        puts d.class
      
      return d.strftime
    end
end
