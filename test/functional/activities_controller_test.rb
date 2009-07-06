require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context "GET to :index" do

      setup { get :index }

      should_respond_with :success
      should_assign_to :tag_types, :activities

    end
    
    context "GET to :index with TagType selected" do

      setup { get :index, :tag_type => {:id => tag_types(:customer).id.to_s} }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :activities

    end
    
    context "GET to :index with Tag selected" do

      setup { get :index, :tag => {:id => tags(:timeflux).id.to_s}, :tag_type_id => tag_types(:customer).id.to_s }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :tag, :activities

    end
    
    context "GET to :new" do
      
      setup { get :new }
      
      should_respond_with :success
      should_assign_to :activity
      
      should "find all tags" do
        tag_count = Tag.count
        assert_equal tag_count, assigns(:tags).size
      end
      
    end
    
    context "GET to :edit" do
      
      setup do
        @id = activities(:timeflux_development).id 
        get :edit, :id => @id
      end
      
      should_respond_with :success
            
      should "find all tags" do
        tag_count = Tag.count
        assert_equal tag_count, assigns(:tags).size
      end
      
      should "find activity 'TimeFlux Development'" do
         assert_equal(@id, assigns(:activity).id)
      end
      
    end
    
    context "successful POST to :create" do
      
      setup do
        @original_activity_count = Activity.count
        post :create, "activity"=>{"name"=>"Foobar", "default_activity"=>"0", "description"=>"Put the foo in the bar", "active"=>"1"}
      end
       
      should_assign_to :activity 
            
      should "redirect to index" do
        assert_redirected_to :action => "index"
      end
      
      should "create a new activity" do
        new_activity_count = Activity.count
        assert_equal(1, new_activity_count - @original_activity_count)
      end
      
    end
    
    context "unsuccessful POST to :create" do
      
      setup do
        @original_activity_count = Activity.count
        post :create, "activity"=>{} # The activities table has a not null constraint on :name
      end
      
      should_assign_to :activity      
      should_render_template :new
            
      should "not create a new activity" do
        new_activity_count = Activity.count
        assert_equal(@original_activity_count, new_activity_count)
      end
      
    end
    
    context "successful PUT to :update" do
      
      setup do
        put :update, "id"=>activities(:timeflux_development).id,
        "activity"=>{"name"=>"TimeFlux Admin", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}        
      end
      
      should_assign_to :activity
      should_set_the_flash_to 'Activity was successfully updated.'
      
      should "redirect to index" do
        assert_redirected_to :action => "index"
      end
      
    end
    
    context "unsuccessful PUT to :update" do
      
      setup do
        put :update, "id"=>activities(:timeflux_development).id,
        "activity"=>{"name"=>"", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}        
      end
      
      should_assign_to :activity, :tags
      should_render_template :edit
      
    end
    
    context "successful DELETE to :destroy" do
      
      setup do
        @id = activities(:timeflux_administration).id
        @original_activity_count = Activity.count
        delete :destroy, "id"=>@id
      end
      
      should "delete activity" do
        new_activity_count = Activity.count
        assert_equal(1, @original_activity_count - new_activity_count)
        assert_nil(Activity.find_by_id(@id))
      end
      
      should "redirect to index" do
        assert_redirected_to activities_url
      end
      
    end
        
    context "unsuccessful DELETE to :destroy for activity with no time entries" do
           
      setup do
        @id = activities(:timeflux_administration).id.to_s
        activity = Activity.find_by_id @id
        activity.stubs(:destroy).returns(false)
        Activity.expects(:find_by_id).at_least_once.with(equals(@id)).returns(activity)
        @original_activity_count = Activity.count
        delete :destroy, "id"=>@id
      end
      
      should "not delete activity" do
        new_activity_count = Activity.count
        assert_equal(@original_activity_count, new_activity_count)
        assert_not_nil(Activity.find_by_id(@id))
      end
      
      should_render_template :edit
      should_assign_to :tags
      
    end
    
    context "unsuccessful DELETE to :destroy for activity with time entries" do
      
      setup do
        @id = activities(:timeflux_development).id.to_s
        @original_activity_count = Activity.count
        delete :destroy, "id"=>@id
      end
      
      should "not delete activity" do
        new_activity_count = Activity.count
        assert_equal(@original_activity_count, new_activity_count)
        assert_not_nil(Activity.find_by_id(@id))
      end
      
      should "set an error message in the flash" do
        assert_equal "Activity has hours registered - could not delete", flash[:error]
      end
      
      should_render_template :edit
      should_assign_to :tags
      
    end
        
  end

  context "User logged out: " do

    should "be redirected to login page on GET to :index" do
      get :index
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on GET to :destroy" do
      get :destroy
      assert_redirected_to new_user_session_url
    end

    should "be redirected to login page on POST to :create" do
      post :create
      assert_redirected_to new_user_session_url
    end

  end

end