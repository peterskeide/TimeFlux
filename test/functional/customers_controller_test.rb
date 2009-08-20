require 'test_helper'

class CustomersControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context " get index" do
      setup { get :index }
      should_respond_with :success
      #assert_not_nil assigns(:customers)
    end

    context "get new" do
      setup { get :new }
      should_respond_with :success
    end

    context "create customer" do
#      assert_difference('Customer.count') do
#        post :create, :customer => { :name => "Norsk rikskringkasting" }
#      end
#
#      assert_redirected_to customer_path(assigns(:customer))
    end

    context "show customer" do
      setup { get :show, :id => customers(:telenor).to_param }
      should_respond_with :success
    end

    context " get edit" do
      setup { get :edit, :id => customers(:telenor).to_param }
      should_respond_with :success
    end

#    context "update customer" do
#      put :update, :id => customers(:cupido).id, :name => "New fancy name goes here!"
#      assert_redirected_to customer_path(assigns(:customer))
#    end
#
#    context "destroy customer" do
##      assert_difference('Customer.count', -1) do
##        delete :destroy, :id => customers(:nsb).to_param
##      end
##
##      assert_redirected_to customers_path
#    end

  end
end
