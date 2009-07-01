require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context "GET to :index" do

      setup { get :index }

      should_respond_with :success
      should_assign_to :tag_types, :activities

    end
    
    context "GET to :index with TagType selected" do

      setup { get :index, :tag_type => {:id => tag_types(:customer).id.to_s} }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :activities

    end
    
    context "GET to :index with Tag selected" do

      setup { get :index, :tag => {:id => tags(:timeflux).id.to_s}, :tag_type_id => tag_types(:customer).id.to_s }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :tag, :activities

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