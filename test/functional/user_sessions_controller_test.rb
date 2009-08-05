require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  context "Logged out," do

    context "accessing the login page" do
      setup { get :new }
      should_render_template :new
      should_not_set_the_flash
    end

    context "login in with correct credentials" do
      setup { post :create, :user_session => {:login => 'bob', :password => 'foo' } }
      should_set_session(:user_credentials_id) { users('bob').id }
      should_redirect_to("Time Entries") { "/time_entries" }
    end

    context "login in with bad credentials" do
      setup { post :create, :login => 'adminuser', :password => 'abc123' }
      should_render_template  :new
    end
  end

  context "Logged in, logging out" do
    setup { login_as(:bill); post :destroy }
    should_set_session(:user_credentials_id) { nil }
    should_redirect_to("Login page") { "/user_sessions/new" }
  end

end