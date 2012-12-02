# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

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
    
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        # flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        # flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

end
