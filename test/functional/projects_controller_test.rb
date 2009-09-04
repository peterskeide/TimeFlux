require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase


  context "User logged in as BOB: " do

    setup { login_as(:bob) }

    context "should get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "call to create" do
      should "create project" do
        assert_difference('Project.count', 1) do
          post :create, :project => { :name => "Kaffedrikkerprosjektet", :customer => customers(:telenor) }
        end
      end
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
      #should_redirect_to(":index") { projects_url }
    end

    context "call to destroy" do
      should "remove project" do
        assert_difference('Project.count', -1) do
          delete :destroy, :id => projects(:pacman).id
        end
      end
    end

  end
end
