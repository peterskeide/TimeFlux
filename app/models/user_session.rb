class UserSession < Authlogic::Session::Base
  include TimeFlux::ConfigurableBehavior::UserSessionModel
end