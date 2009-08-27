require File.dirname(__FILE__) + '/../test_helper'

class HourTypesControllerTest < ActionController::TestCase
 
 context "When logged in as Bob (administrator)" do
   
   setup { login_as :bob }
   
   context "GET to :index" do
     
     setup { get :index }
     
     should_respond_with :success
     should_assign_to :hour_types
     should_render_template :index
     
   end
   
   context "GET to :new" do
     
     setup { get :new }
     
     should_respond_with :success
     should_assign_to :hour_type
     should_render_template :new
     
   end
   
   context "GET to :edit for an existing hour type" do
     
     setup { get :edit, :id => hour_types(:normaltid).id }

     should_assign_to :hour_type
     should_render_template :edit
     
   end
   
   context "GET to :edit for a hour type that does not exist" do
     
     setup { get :edit, :id => 4000 }

      should_redirect_to("Hour Types index") { hour_types_url }
      should_set_the_flash_to "The requested resource does not exist"
     
   end
   
   context "a successful POST to :create" do
     
     setup { post :create, :hour_type => { :name => "Foo", :default_hour_type => false } }
     
     should_redirect_to("Hour Types index") { hour_types_url }
     should_change "HourType.count", :by => 1
     should_set_the_flash_to "Hour Type created"
     
   end
   
   context "an unsuccessful POST to :create" do
     
     setup { post :create, :hour_type => { :name => "", :default_hour_type => false } }# lack of name will trigger an error
     
     should_render_template :new
     should_not_change "HourType.count"
     should_set_the_flash_to "Unable to create Hour Type"
     
   end
   
   context "a successful PUT to :update for an existing hour type" do
     
     setup { put :update, :hour_type => {:name => "Foo"}, :id => hour_types(:normaltid).id }
     
     should_redirect_to("Hour Types index") { hour_types_url }
     should_set_the_flash_to "Hour Type updated"
     
     should "update name of hour type" do
       assert_equal("Foo", HourType.find(hour_types(:normaltid).id).name)
     end
     
   end
   
   context "an unsuccessful PUT to :update for an existing hour type" do
     
     setup { put :update, :hour_type => {:name => ""}, :id => hour_types(:normaltid).id }
     
     should_render_template :edit
     should_set_the_flash_to "Unable to update Hour Type"
     
     should "not update name of hour type" do
        assert_equal("Normaltid", HourType.find(hour_types(:normaltid).id).name)
      end
     
   end
   
   context "PUT to :update for an hour type that does not exist" do
     
     setup { put :update, :hour_type => {:name => "Foo"}, :id => 4000 }
     
     should_redirect_to("Hour Types index") { hour_types_url }
     should_set_the_flash_to "The requested resource does not exist"
     
   end
   
   context "DELETE to :destroy" do
     
     setup { delete :destroy, :id => hour_types(:normaltid).id }
     
     should_change "HourType.count", :by => -1
     should_redirect_to("Hour Types index") { hour_types_url }
     should_set_the_flash_to "Hour Type deleted"
      
   end
      
 end
 
 context "When logged in as Bill (not administrator)" do
   
   setup { login_as :bill }
   
   context "GET to :index" do    
      setup { get :index }    
      should_redirect_to("Time Entries index for Bill") { user_time_entries_url(:user_id => users(:bill).id) }    
    end
   
 end
 
 context "When not logged in" do
   
   context "GET to :index" do    
     setup { get :index }    
     should_redirect_to("Login page") { new_user_session_url }    
   end
   
 end
  
end