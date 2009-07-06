class UserSession < Authlogic::Session::Base
  verify_password_method(:valid_ldap_credentials?) if TimeFlux::CONFIG.use_ldap
end