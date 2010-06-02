ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
 
require "authlogic/test_case"

class ActiveSupport::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

  def login_as(user)
    UserSession.create(users(user)) # logs a user in
  end
  
  def assert_false(condition)
    assert(!condition)
  end
  
  # A bit hackish, but arguably better than not having tests for these cases
  def assert_javascript_function_call(css_selector, function)
    exp = "$$(\"#{css_selector}\").each(function(value, index) {\nvalue.#{function}();\n});"
    assert(@response.body.match(Regexp.escape(exp)))
  end
  
end

class ActionController::TestCase
  setup :activate_authlogic
end