class ApplicationController < ActionController::Base
  
  helper :all
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fde529db0c28312f59bd56fca26f2acf'
  filter_parameter_logging :password
  
  helper_method :current_user_session, :current_user
  
  before_filter :set_time_zone

  private
  
  def set_time_zone
    Time.zone = Configuration.instance.time_zone
  end

  def redirect_to_ssl
    unless params[:ssl]== "false"
      redirect_to :protocol => "https://" unless (request.ssl? or local_request?)
    else
      puts "Redirect override"
    end
  end

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
  
  def check_user
    unless current_user.admin || params[:id] == current_user.id.to_s
      flash[:notice] = "You do not have access to this page"
       redirect_to user_time_entries_url(current_user)
       return false
    end
  end
  
  def check_parent_user
    unless current_user.admin || params[:user_id] == current_user.id.to_s
      flash[:notice] = "You do not have access to this page"
       redirect_to new_user_session_url
       return false
    end
  end

  private

  # Updated to also handle IPv6
  # See - https://rails.lighthouseapp.com/projects/8994/tickets/3257-local_request-does-not-detect-local-ipv6-connections
  #
  def local_request?
    request.remote_addr == LOCALHOST && request.remote_ip == LOCALHOST ||
    request.remote_addr == "::1" && request.remote_ip == "::1"
  end
 
end