require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context 'Logged in as Bob' do

    setup do
      login_as(:bob)
    end

    context "With users" do

      context "a GET to :index" do
        setup { get :index }
        should_render_template :index
        should_not_set_the_flash
      end

      context "a GET to :new" do
        setup { get :new }
        should_render_template :new
        should_not_set_the_flash
      end

      context "a POST to :create" do
        setup { i=0; post :create, :user => {:firstname => 'Ronald', :lastname => 'McDonald', :email => 'me@one.com', :password => "something", :password_confirmation => "something", :login => "uniq_#{i=i+1}" } }
        should_redirect_to("New user") { "/users/#{assigns(:user).id}" }
        should_assign_to :user
        should_set_the_flash_to(/created/i)
      end

      context "a POST to :create supplying an existing username" do
        setup { post :create, :user => {:firstname => 'Ronald', :lastname => 'McDonald', :password => "something", :password_confirmation => "something", :login => users(:bob).login } }
        should_render_template :new
        should_set_the_flash_to(/Could not create/i)
      end

      context "a GET to :edit" do
        setup { get :edit, :id => users(:bob).id }
        should_respond_with :success
        should_render_template :edit
      end

    end

  end
  
  context 'Logged in as bill on GET to :index' do
    setup { login_as(:bill); get :index }
    should_redirect_to("Time Entries") { "/time_entries" }
  end

  context "Not logged in on GET to :index" do
    setup { get :index }
    should_redirect_to("Login page") { "/user_sessions/new" }
  end    
  
end
