require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  
  context "User logged in: " do
    
    setup { mock_login }
    
    context "GET to :index" do
      
      setup { get :index }
              
      should_respond_with :success
      
      should "find all categories" do
        get :index
        assigned_categories = assigns(:categories)
        assert_not_nil assigned_categories
        assert_equal 3, assigned_categories.size
      end
      
    end
    
    context "GET to :destroy" do
      
      setup do
        @category = mock
        @category.stubs(:name).returns("Foo")
        @category.stubs(:activities).returns([])
        @to_destroy = Category.new       
      end 

      should "fail if category has activities" do        
        get :destroy, :id => categories(:internal_projects)
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
    
    context "POST to :create" do
      
      setup do
        @category = mock
        Category.stubs(:new).returns(@category)
      end
      
      should "save a new category" do
        @category.expects(:save).returns(true)
        post :create, :category => {:name => "Foo"}
      end
      
      should "redirect to :index if successful" do
        @category.stubs(:save).returns(true)
        post :create, :category => {:name => "Foo"}
        assert_redirected_to(:action => "index")
      end
      
      should "redirect to :index if save fails" do
        @category.stubs(:save).returns(false)
        post :create, :category => {:name => "Foo"}
        assert_redirected_to(:action => "index")
      end
      
    end
        
  end
      
end