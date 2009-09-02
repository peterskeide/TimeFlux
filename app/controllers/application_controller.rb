class ApplicationController < ActionController::Base
  
  helper :all
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fde529db0c28312f59bd56fca26f2acf'
  filter_parameter_logging :password
  
  helper_method :current_user_session, :current_user

  private
  
  def current_user_session
    return @current_user_session if defined? @current_user_session
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = current_user_session && current_user_session.user
  end
  
  def check_authentication
     unless current_user
       flash[:notice] = "Please log in first"
       redirect_to new_user_session_url
       return false
     end
  end
  
  def check_admin
    unless current_user.admin
      flash[:notice] = "That page is for admins only"
       redirect_to user_time_entries_url(current_user)
       return false
    end
  end
  
end