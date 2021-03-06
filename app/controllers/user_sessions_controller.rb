class UserSessionsController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create, :index]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    
    @user_session.save do |result|
      if result
        flash[:notice] = "Login successful!"
        redirect_back_or_default root_url
      else
        render :action => :new
      end
    end
  end
  
  def destroy
    CategoryCache.get_from_session(session).refresh
    
    current_user_session.destroy
    
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end