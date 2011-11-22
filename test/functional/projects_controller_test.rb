require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "User logged in as BOB: " do

    setup { login_as(:bob) }

    context "should get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "call to create" do
      should "create project" do
        assert_difference('Project.count', 1) do
          post :create, :project => { :name => "Kaffedrikkerprosjektet", :customer => customers(:global_corp) }
        end
      end
      
      context "creating a project for a customer that already has a project with the given name" do
        setup { post :create, :project => { :name => projects(:pacman).name, :customer => customers(:global_corp) } }
        should_render_template :new
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
      setup do
        @pacman = projects(:pacman)
        put :update, :id => @pacman.to_param, :project => { }
      end
      should_redirect_to("The projects customer page") { customer_url(:id=> @pacman.customer.id) }
    end

    context "updating a project for a customer that already has a project with the given name" do
      setup { post :update, :id => projects(:fri99).id, :project => { :name => projects(:pacman).name, :customer => customers(:global_corp) } }
      should_render_template :edit
    end

    context "call to destroy" do
      should "remove project" do
        assert_difference('Project.count', -1) do
          delete :destroy, :id => projects(:unused).id
        end
      end
    end

    context "POST to assign_to_users" do
      setup do
        @community = projects(:community)
        post :assign_to_users, :project_id => @community.id, :users => [users(:bob).id]
      end

      should "assign bob to the project" do
        assert @community.users.first.firstname == "Bob"
      end
    end

    context "POST to remove_user_assignment" do
      setup do
        @pacman = projects(:pacman)
        post :remove_user_assignment, :id => @pacman.id, :user => users(:bob).id
      end

      should "reduce the number of assignments for the project" do
        assert @pacman.users.count == 0
      end
    end

  end
end
