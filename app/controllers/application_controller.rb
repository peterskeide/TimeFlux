class ApplicationController < ActionController::Base
  
  helper :all
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fde529db0c28312f59bd56fca26f2acf'
  filter_parameter_logging :password
  
end