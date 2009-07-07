require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  context "User logged in: " do

    setup { login_as(:bob) }

    context "GET to :index" do

      setup { get :index }

      should_respond_with :success
      should_assign_to :tag_types, :activities

    end
    
    context "POST to :filter_by_tag_type" do

      setup { post :filter_by_tag_type, :tag_type => {:id => tag_types(:customer).id.to_s} }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :activities

    end
    
    context "POST to :filter_by_tag" do

      setup { post :filter_by_tag, :tag => {:id => tags(:timeflux).id.to_s}, :tag_type_id => tag_types(:customer).id.to_s }

      should_respond_with :success
      should_assign_to :tag_types, :tag_type, :tag, :activities

    end
    
    context "GET to :new" do
      
      setup { get :new }
      
      should_respond_with :success
      should_assign_to :activity
      
    end
    
    context "GET to :edit" do
      
      setup do
        @id = activities(:timeflux_development).id 
        get :edit, :id => @id
      end
      
      should_respond_with :success
            
      should "find all unselected tags" do
        assert_equal(1, assigns(:tags).size)
      end
      
      should "find activity 'TimeFlux Development'" do
         assert_equal(@id, assigns(:activity).id)
      end
      
    end
    
    context "successful POST to :create" do
      
      setup do
        post :create, "activity"=>{"name"=>"Foobar", "default_activity"=>"0", "description"=>"Put the foo in the bar", "active"=>"1"}
      end
       
      should_change "Activity.count", :by => 1            
      should_redirect_to(":index") { activities_url }
            
    end
    
    context "unsuccessful POST to :create" do
      
      setup do
        @original_activity_count = Activity.count
        post :create, "activity"=>{} # The activities table has a not null constraint on :name
      end
      
      should_assign_to :activity      
      should_render_template :new
      should_not_change "Activity.count"      
      
    end
    
    context "PUT to :update" do
    
      setup do
        @activity = Activity.find_by_id(activities(:timeflux_development).id)
      end
    
      context "successful path" do
      
        setup do
          put :update, "id"=>@activity.id,
          "activity"=>{"name"=>"TimeFlux Admin", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}        
        end
      
        should_assign_to :activity
        should_set_the_flash_to 'Activity was successfully updated.'      
        should_redirect_to(":index") { activities_url }
      
      end
    
      context "unsuccessful path" do
      
        setup do
          put :update, "id"=>@activity.id,
          "activity"=>{"name"=>"", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}        
        end
      
        should_assign_to :activity, :tags, :users
        should_render_template :edit
        should_not_change "@activity.name"
      
      end
    
    end
    
    context "successful DELETE to :destroy" do
      
      setup do
        @id = activities(:timeflux_administration).id
        delete :destroy, "id"=>@id
      end
      
      should_change "Activity.count", :by => -1
      should_set_the_flash_to "Activity successfully removed"      
      should_redirect_to(":index") { activities_url }
           
    end
        
    context "unsuccessful DELETE to :destroy for activity with no time entries" do
           
      setup do
        @id = activities(:timeflux_administration).id.to_s
        activity = Activity.find_by_id @id
        activity.stubs(:destroy).returns(false)
        Activity.expects(:find_by_id).at_least_once.with(equals(@id)).returns(activity)
        delete :destroy, "id"=>@id
      end
      
      should_not_change "Activity.count"      
      should_render_template :edit
      should_assign_to :tags, :users, :activity
      
    end
    
    context "unsuccessful DELETE to :destroy for activity with time entries" do
      
      setup do
        @id = activities(:timeflux_development).id.to_s
        delete :destroy, "id"=>@id
      end
      
      should_not_change "Activity.count"           
      should_render_template :edit
      should_assign_to :tags, :users, :activity
      
    end
    
    context "POST to :add_tag" do
      
      setup do
        @tag = tags(:timeflux)
        @activity = activities(:timeflux_administration) 
        post :add_tag, :tag => @tag.id, :activity => {:id => @activity.id}
      end
      
      should_redirect_to(":edit") { edit_activity_url(@activity) }
      
      should "add selected tag to activity" do
        assert(@activity.tags.include?(@tag))
      end
      
    end
    
    context "GET to :remove_tag" do
      
      setup do
        @activity = activities(:timeflux_development)
        @tag = tags(:timeflux)
        get :remove_tag, :id => @activity.id, :tag => @tag.id
      end
      
      should_redirect_to(":edit") { edit_activity_url(@activity) }
      
      should "remove selected tag from activity" do
         assert_false(@activity.tags.include?(@tag))
      end
      
    end
    
    context "POST to :add_user" do
      
      setup do
        @bob = users(:bob)
        @activity = activities(:timeflux_administration)
        post :add_user, "user" => @bob.id, "activity" => {"id" => @activity.id}
      end
      
      should_redirect_to(":edit") { edit_activity_url(@activity) }
      
      should "add selected user to activity" do
        assert(@activity.users.include?(@bob))
      end
      
    end
    
    context "GET to :remove_user" do
      
      setup do
        @activity = activities(:timeflux_development)
        @bill = users(:bill)
        get :remove_user, :id => @activity.id, :user => @bill.id
      end
      
      should_redirect_to(":edit") { edit_activity_url(@activity) }
      
      should "remove selected user from activity" do
         assert_false(@activity.users.include?(@bill))
      end
      
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
    
    should "be redirected to login page on POST to :filter_by_tag_type" do
      post :filter_by_tag_type
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on POST to :filter_by_tag" do
      post :filter_by_tag
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on GET to :edit" do
      get :edit
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on GET to :new" do
      get :new
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on PUT to :update" do
      put :update
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on POST to :add_tag" do
      post :add_tag
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on POST to :add_user" do
      post :add_user
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on GET to :remove_tag" do
      get :remove_tag
      assert_redirected_to new_user_session_url
    end
    
    should "be redirected to login page on GET to :remove_user" do
      get :remove_user
      assert_redirected_to new_user_session_url
    end

  end

end