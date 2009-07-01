class UserSession < Authlogic::Session::Base
  verify_password_method :valid_ldap_credentials?
end