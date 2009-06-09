require File.dirname(__FILE__) + "/../spec_helper"

describe CategoriesController do
  
  before do
    user_session = mock_model(UserSession)
    user = mock_model(User)
    UserSession.stub(:find).and_return(user_session)
    user_session.stub!(:user).and_return(user)
  end
  
  describe "action: index" do
  
    it "should be successful" do
      get :index
      response.should be_success
    end
  
    it "should find all categories" do
      Category.should_receive(:find).with(:all).and_return([@category])
      get :index
    end
  
  end
  
  describe "action: destroy" do

    before do
      @category = mock_model(Category)
      @category.stub!(:name).and_return("Foo")
      @category.stub!(:activities).and_return([])
      @to_destroy = Category.new
    end

    it "should find the selected category" do
       Category.should_receive(:find).with(@to_destroy).and_return(@category)
       @category.stub!(:destroy)
       get :destroy, :id => @to_destroy    
    end

    it "should fail if category has activities"

    it "should destroy the selected category" do
       Category.stub!(:find).and_return(@category)
       @category.should_receive(:destroy)
       get :destroy, :id => @to_destroy     
    end

    it "should redirect to index" do
      Category.stub!(:find).and_return(@category)
      @category.should_receive(:destroy)
      get :destroy, :id => @to_destroy
      response.should redirect_to(:action => "index")
    end

  end

  describe "action: create" do

    it "should create"

  end
  
end