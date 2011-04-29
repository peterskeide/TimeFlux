require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase

  context "When logged in as Bob (administrator)" do

    setup { login_as :bob }

    context "GET to :index" do
      setup { get :index }
      should_respond_with :success
      should_assign_to :departments
      should_render_template :index
    end

    context "get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "call to create" do
      should "create new department" do
        assert_difference('Department.count', 1) do
          post :create, :department => { :name => "Vedlikehold", :internal_id => 800 }
        end
      end
    end

    context "call to create with an existing name" do
      setup { post :create, :department => { :name => departments(:one).name, :internal_id => 999 } }
      should_not_change("the number of customers") { Customer.count }
    end

    context "show customer" do
      setup { get :show, :id => departments(:one).to_param }
      should_respond_with :success
    end

    context " get edit" do
      setup { get :edit, :id => departments(:one).to_param }
      should_respond_with :success
    end

    context "update department" do
      setup { put :update, :id => departments(:one).id, :name => "New fancy name goes here!" }
      should_redirect_to("show") { department_url(departments(:one)) }
    end

    context "call to destroy" do
      should "remove department" do
        assert_difference('Department.count', -1) do
          delete :destroy, :id => departments(:one).id
        end
      end
    end
  end
end
