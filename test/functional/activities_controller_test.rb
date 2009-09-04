require File.dirname(__FILE__) + '/../test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  context "When logged in as Bob" do

    setup { login_as(:bob) }
    
    context "GET to :index" do

      setup { get :index }
      should_respond_with :success
      should_assign_to :activities

    end

    context "GET to :new" do
      
      setup { get :show, :id => 4000 }
      should_set_the_flash_to "The requested resource does not exist"
      should_redirect_to("Activities index") { activities_url }
      
    end
    
    context "GET to :edit for an existing activity" do
      
      setup do
        @id = activities(:timeflux_development).id 
        get :edit, :id => @id
      end
      
      should_respond_with :success
      should_render_template :edit
      
      should "find activity 'TimeFlux Development'" do
         assert_equal(@id, assigns(:activity).id)
      end
      
    end
    
    context "GET to :edit for a non existant activity" do
      
      setup do
        get :edit, :id => 4000
      end
      
      should_set_the_flash_to "The requested resource does not exist"
      should_redirect_to("Activities index") { activities_url }
      
    end
    
    context "a successful POST to :create" do
      
      setup do
        post :create, "activity"=>{"name"=>"Foobar", "default_activity"=>"0", "description"=>"Put the foo in the bar", "active"=>"1", "tag_ids" => "#{tags(:timeflux).id}"}
      end
       
      should_change("the number of activities", :by => 1) { Activity.count }           
      should_redirect_to("Activities index") { activities_url }
      should_set_the_flash_to "New Activity was created"
            
    end
    
    context "an unsuccessful POST to :create" do
      
      setup do
        @original_activity_count = Activity.count
        post :create, "activity"=>{} # The activities table has a not null constraint on :name
      end
      
      should_assign_to :activity      
      should_render_template :new
      should_not_change("the number of activities") { Activity.count }
      should_set_the_flash_to "Unable to create activity"
      
    end
    
    context "a successful PUT to :update for an existing activity" do
    
      setup do
        @activity = Activity.find_by_id(activities(:timeflux_development).id)
        put :update, "id"=>@activity.id,
        "activity"=>{"name"=>"TimeFlux Admin", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}
      end
      
      should_set_the_flash_to "Activity updated"
      should_redirect_to("Activities index") { project_url(:id => @activity.project.id) }
      
      should "update the changed attributes of the activity" do
        @activity.reload
        assert_equal("TimeFlux Admin", @activity.name)
      end
        
    end
    
    context "an unsuccessful PUT to :update for an existing activity" do
    
      setup do
        @activity = Activity.find_by_id(activities(:timeflux_development).id)
        put :update, "id"=>@activity.id,
        "activity"=>{"name"=>"", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}
      end
      
      should_set_the_flash_to "Unable to update activity"
      should_render_template :edit
      should_assign_to :activity
      
      should "not update the changed attributes of the activity" do
        @activity.reload
        assert_equal("TimeFlux Development", @activity.name)
      end
        
    end
    
    context "PUT to :update for an activity that does not exist" do
    
      setup do
        put :update, "id"=>4000,
        "activity"=>{"name"=>"TimeFlux Admin", "default_activity"=>"1", "description"=>"Administration of TimeFlux in production", "active"=>"0"}
      end
      
      should_set_the_flash_to "The requested resource does not exist"
      should_redirect_to("Activities index") { activities_url }
        
    end
    
    context "DELETE to :destroy for an activity with no time entries" do
      
      setup do
        @id = activities(:timeflux_administration).id
        delete :destroy, "id"=>@id
      end
      
      should_change("the number of activities", :by => -1) { Activity.count }
      should_set_the_flash_to "Activity successfully removed"
      should_redirect_to("Activities index") { activities_url }
           
    end
        
    context "DELETE to :destroy for an activity with time entries" do
           
      setup do
        @activity = Activity.find_by_id(activities(:timeflux_development).id)
        delete :destroy, "id"=> @activity.id
      end
      
      should_not_change("the number of activities ") { Activity.count }           
      should_set_the_flash_to "Activities with time entries cannot be removed"
      should_redirect_to("Activities index") { project_url(:id => @activity.project.id) }
      
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