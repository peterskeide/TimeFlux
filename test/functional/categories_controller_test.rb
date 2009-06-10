require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  
  context "User logged in: " do
    
    setup do
      user_session = mock
      user = mock
      UserSession.stubs(:find).returns(user_session)
      user_session.stubs(:user).returns(user)
    end
    
    context "GET to index" do
      
      setup do
        get :index
      end
      
      should_respond_with :success
      
      should "find all categories" do
        @category = Category.new
        Category.expects(:find).with(any_parameters).returns([@category])
        get :index
      end
      
    end
        
  end
      
end