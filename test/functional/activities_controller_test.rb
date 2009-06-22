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

    context "GET to :destroy" do

      should "fail if category has activities" do
        assert_no_difference('Category.count') do
          get :destroy, :id => categories(:internal_project)
        end
        assert_redirected_to(:action => "index")
        assert_not_nil flash[:error]
      end

      should "destroy the selected category" do
        assert_difference('Category.count', -1) do
          get :destroy, :id => categories(:meeting)
        end
      end

      should "redirect to index" do
        get :destroy, :id => categories(:meeting)
        assert_redirected_to(:action => "index")
      end

    end

    context "POST to :create" do

      should "save a new category" do
        assert_difference('Category.count') do
          post :create, :category => {:name => "Foo"}
        end
      end

      should "redirect to :index if successful" do
        post :create, :category => {:name => "Foo"}
        assert_redirected_to(:action => "index")
      end

      should "redirect to :index if save fails" do
        post :create, :category => {:name => ""}
        assert_redirected_to(:action => "index")
        assert_not_nil flash[:error]
      end

    end

  end

  context "Logged out user" do

    should "be redirected to login page on GET to :index" do
      get :index
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on GET to :destroy" do
      get :destroy, :id => categories(:meeting)
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on POST to :create" do
      post :create, :category => {:name => "Foo"}
      assert_redirected_to new_user_session_url
    end

  end

end