require 'test_helper'

class ConfigurationsControllerTest < ActionController::TestCase
  
  context "When logged in as an administrator" do
    
    setup { login_as :bob }
  
    context "GET to :edit" do
      
      setup { get :edit }
      
      should_respond_with :success
      should_assign_to :config
      should_render_template :edit      
      
    end
    
    context "a successful PUT to :update" do
      
      setup { put :update, :configuration => { :time_zone => "UTC", :work_hours => 5.0, :activity_id => activities(:vacation).id } }
      
      should_set_the_flash_to "Configuration updated"
      should_redirect_to("edit configuration page") { edit_configuration_url }
      
      should "update configuration options" do 
        config = Configuration.instance
        assert_equal("UTC", config.time_zone)
        assert_equal(5.0, config.work_hours)
        assert_equal(activities(:vacation), config.vacation_activity)
      end
      
    end
    
    context "a unsuccessful PUT to :update" do
      
      setup { put :update, :configuration => { :time_zone => "", :work_hours => 5.0, :activity_id => activities(:vacation).id } }
      
      should_set_the_flash_to "Failed to update configuration"
      should_redirect_to("edit configuration page") { edit_configuration_url }
      
    end 
  
  end
  
  context "When logged in as a normal user" do
    
    setup { login_as :bill }
    
    context "GET to :edit" do    
      setup { get :edit }      
      should_redirect_to("time entries index") { user_time_entries_url(users(:bill)) }     
    end
    
    context "PUT to :update" do    
      setup { put :update }      
      should_redirect_to("time entries index") { user_time_entries_url(users(:bill)) }     
    end
    
  end
   
end