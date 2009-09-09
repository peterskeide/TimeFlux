require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  context "Logged out," do
    
    setup { @request.env['HTTPS'] = 'on' }

    context "accessing the login page" do
      setup { get :new }
      should_render_template :new
      should_not_set_the_flash
      should "display a login form" do
        assert_select 'form#new_user_session'
      end
    end

    context "login in with correct credentials" do
      setup { post :create, :user_session => {:login => 'bob', :password => 'foo' } }
      should_set_session(:user_credentials_id) { users('bob').id }
      should_redirect_to("Time Entries") { user_time_entries_url(users(:bob).id) }
    end

    context "login in with bad credentials" do
      setup { post :create, :login => 'adminuser', :password => 'abc123' }
      should_render_template  :new
    end
  end

  context "Logged in, logging out" do
    setup { @request.env['HTTPS'] = 'on'; login_as(:bill); post :destroy }
    should_set_session(:user_credentials_id) { nil }
    should_redirect_to("Login page") { "/user_sessions/new" }
  end

  context "get :new with http" do
    setup { get :new; @request.env['HTTPS'] = nil }
    should_redirect_to("SSL") {"https://" + @request.host + @request.request_uri }
  end


end