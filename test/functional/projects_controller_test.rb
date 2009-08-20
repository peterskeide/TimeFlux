require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase


  context "User logged in as BOB: " do

    setup { login_as(:bob) }

    context "should get index" do
      setup { get :index }
      should "yeah" do
      assert_response :success
      assert_not_nil assigns(:projects)
      end
    end

    context "should get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "should create project" do
#      assert_difference('Project.count') do
#        post :create, :project => { }
#      end
#
#      assert_redirected_to project_path(assigns(:project))
    end

    context "should show project" do
      setup { get :show, :id => projects(:pacman).to_param }
      should_respond_with :success
    end

    context "should get edit" do
      setup { get :edit, :id => projects(:pacman).to_param }
      should_respond_with :success
    end

    context "should update project" do
      setup { put :update, :id => projects(:pacman).to_param, :project => { } }
      #assert_redirected_to project_path(assigns(:project))
    end

    context "should destroy project" do
#      assert_difference('Project.count', -1) do
#        delete :destroy, :id => projects(:one).to_param
#      end
#
#      assert_redirected_to projects_path
    end

  end
end
