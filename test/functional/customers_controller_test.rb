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

    context "show customer" do
      setup { get :show, :id => customers(:telenor).to_param }
      should_respond_with :success
    end

    context " get edit" do
      setup { get :edit, :id => customers(:telenor).to_param }
      should_respond_with :success
    end

    context "update customer" do
      setup { put :update, :id => customers(:cupido).id, :name => "New fancy name goes here!" }
      should_redirect_to("show") { customer_url(customers(:cupido)) }
    end
    
    context "call to destroy" do
      should "remove customer" do
        assert_difference('Customer.count', -1) do
          delete :destroy, :id => customers(:nsb).id
        end
      end
    end
  end
end
