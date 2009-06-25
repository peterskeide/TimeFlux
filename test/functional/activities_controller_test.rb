require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context "GET to :index" do

      setup { get :index }

      should_respond_with :success

      should "find all activities" do
        get :index
        #assigned_categories = assigns(:categories)
        #assert_equal 3, assigned_categories.size
      end

    end
    
  end

  context "Logged out user" do

    should "be redirected to login page on GET to :index" do
      get :index
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on GET to :destroy" do
      get :destroy
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on POST to :create" do
      post :create
      assert_redirected_to new_user_session_url
    end

  end

end