require 'test_helper'

class CustomersControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context " get index" do
      setup { get :index }
      should_respond_with :success
      should_assign_to :customers
    end

    context "get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "call to create" do
      should "create customer" do
        assert_difference('Customer.count', 1) do
          post :create, :customer => { :name => "Norsk rikskringkasting" }
        end    
      end
    end

    context "call to create with an existing name" do
      setup { post :create, :customer => { :name => customers(:global_corp).name } }
      should_not_change("the number of customers") { Customer.count }
    end

    context "show customer" do
      setup { get :show, :id => customers(:global_corp).to_param }
      should_respond_with :success
    end

    context " get edit" do
      setup { get :edit, :id => customers(:global_corp).to_param }
      should_respond_with :success
    end

    context "update customer" do
      setup { put :update, :id => customers(:global_corp).id, :name => "New fancy name goes here!" }
      should_redirect_to("show") { customers_url() }
    end
    
    context "call to destroy" do
      should "remove customer" do
        assert_difference('Customer.count', -1) do
          delete :destroy, :id => customers(:sokadu).id
        end
      end
    end
  end
end
