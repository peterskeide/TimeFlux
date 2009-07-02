class UserSession < Authlogic::Session::Base
  TimeFlux.configure self
end