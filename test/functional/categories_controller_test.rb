require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  
  context "User logged in: " do
    
    setup do
      mock_login
    end
    
    context "on GET to :index" do
      
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
    
    context "on GET to :destroy" do
      
      setup do
        @category = mock
        @category.stubs(:name).returns("Foo")
        @category.stubs(:activities).returns([])
        @to_destroy = Category.new       
      end 
      
      should "find the selected category" do
        @category.stubs(:destroy)
        Category.expects(:find).with(@to_destroy).returns(@category)         
        get :destroy, :id => @to_destroy             
      end

      should "fail if category has activities" do
        @category.expects(:destroy).never
        @category.stubs(:activities).returns([Activity.new])        
        Category.stubs(:find).with(@to_destroy).returns(@category)        
        get :destroy, :id => @to_destroy
        assert_redirected_to(:action => "index")
      end

      should "destroy the selected category" do
        Category.stubs(:find).returns(@category)
        @category.expects(:destroy)
        get :destroy, :id => @to_destroy
      end

      should "redirect to index" do
        Category.stubs(:find).returns(@category)
        @category.expects(:destroy)
        get :destroy, :id => @to_destroy
        assert_redirected_to(:action => "index")
      end
            
    end
    
    context "on POST to :create" do
      
      setup do
      end
      
    end
        
  end
      
end