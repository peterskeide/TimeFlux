require File.dirname(__FILE__) + '/../test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
        
  context "User logged in: " do
    
    setup do
      login_as :bob
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end
             
    context "GET to :index with no date param" do
            
      setup { get :index, :user_id => users(:bob).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :date, :user
      should_render_template :index
                
    end
    
    context "GET to :index with date from previous week" do
      
      setup { get :index, :user_id => users(:bob).id, :date => @date.-(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assign date from previous week" do
        date = assigns(:date)
        assert_equal(25, date.cweek)
      end
      
    end
    
    context "GET to :index with date from next week" do
      
      setup { get :index, :user_id => users(:bob).id, :date => @date.+(7).to_s }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :user
      should_render_template :index
      
      should "assign date from next week" do
        date = assigns(:date)
        assert_equal(27, date.cweek)
      end
      
    end
           
    context "GET to :new without javascript" do
      
      setup { get :new, :user_id => users(:bob).id, :date => @date.to_s, :day => "Monday" }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :activities, :user
      should_render_template :new
                 
    end
    
    context "GET to :new with javascript" do
      
      setup { xhr :get, :new, :user_id => users(:bob).id, :date => @date.to_s, :day => "Monday" }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :activities, :user
      should_render_template "time_entries/time_entries_with_form.rjs"
           
    end
    
    context "GET to :edit without javascript" do
      
      setup { get :edit, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :activities, :user
      should_render_template :edit
      
    end
    
    context "GET to :edit with javascript" do
      
      setup { xhr :get, :edit, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :success
      should_not_set_the_flash
      should_assign_to :time_entry, :user, :activities
      should_render_template "time_entries/time_entries_with_form.rjs"
     
    end
        
    context "successful POST to :create without javascript" do
      
      setup { 
        post :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 3.0, :hour_type_id => hour_types(:normaltid).id } 
      }
      
      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Time Entry saved"
      should_redirect_to("index") { user_time_entries_path(:user_id => users(:bob).id, :date => @date.to_s) }
      should_change("the number of time entries", :by => 1) { TimeEntry.count }
      
    end
    
    context "unsuccessful POST to :create without javascript" do
      
      setup {
        # Hours cannot be 0. This will trigger a validation error. 
        post :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 0.0, :hour_type_id => hour_types(:normaltid).id } 
      }
       
      should_assign_to :user
      should_render_template :new
      should_set_the_flash_to "Unable to create time entry"
      should_not_change("the number of time entries") { TimeEntry.count }
      
    end
    
    context "successful POST to :create with javascript" do
      
      setup { 
        xhr :post, :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 3.0, :hour_type_id => hour_types(:normaltid).id } 
      }
      
      should_assign_to :user
      should_change("the number of time entries", :by => 1) { TimeEntry.count }     
      should_respond_with :success
            
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end
      
      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "10.5"
        end
      end
            
    end
    
    context "unsuccessful POST to :create with javascript" do
      
      setup {
        xhr :post, :create, :user_id => users(:bob).id, 
        :time_entry => { :date => @date.to_s, :activity_id => activities(:timeflux_development).id, :notes =>"Foo", :hours => 0.0, :hour_type_id => hour_types(:normaltid).id } 
      }
      
      should_assign_to :time_entry, :activities, :user
      should_not_change("the number of time entries") { TimeEntry.count }
      
      should "display error messages" do
        assert_select_rjs :replace_html, "Monday_time_entry_error_messages" do
          assert_select "p.error", assigns(:time_entry).errors.full_messages.to_s 
        end
      end
      
    end
            
    context "successful PUT to :update without javascript" do

      setup { 
        put :update, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id, 
        :time_entry => { :notes => "Foo", :hours => 3.0 } 
      }
       
      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Time Entry updated"
      should_redirect_to("index") { user_time_entries_path(:user_id => users(:bob).id, :date => @date.to_s) }
      
      should "update hours field of the selected time entry" do
        assert_equal 3.0, TimeEntry.find(time_entries(:bob_timeflux_development_26_monday).id).hours
      end

    end
    
    context "unsuccessful PUT to :update without javascript" do
      
      setup {
        put :update, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id, 
        :time_entry => { :notes =>"Foo", :hours => 0.0 } 
      }
      
      should_assign_to :time_entry, :user
      should_render_template :edit
      should_set_the_flash_to "Unable to update time entry"
      
    end
    
    context "successful PUT to :update with javascript" do
      
      setup { 
        xhr :put, :update, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id, 
        :time_entry => { :notes => "Foo", :hours => 3.0 } 
      }
      
      should_respond_with :success
      should_assign_to :time_entry, :user
      
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end
      
      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "3.0"
        end
      end
      
    end
    
    context "unsuccessful PUT to :update with javascript" do
      
      setup {
        @id = time_entries(:bob_timeflux_development_26_monday).id 
        xhr :put, :update, :user_id => users(:bob).id, :id => @id, 
        :time_entry => { :notes => "Foo", :hours => 0.0 } 
      }
      
      should_assign_to :time_entry, :activities, :user
      
      should "display error messages" do
        assert_select_rjs :replace_html, "Monday_time_entry_error_messages" do
          assert_select "p.error", assigns(:time_entry).errors.full_messages.to_s 
        end
      end
    
    end
        
    context "DELETE to :confirm_destroy (no javascript)" do
      
      setup { delete :confirm_destroy, :user_id => users(:bob).id, :date => @date.to_s, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_assign_to :time_entry, :date, :user
      should_render_template :confirm_destroy
      should_respond_with :success
      
    end
    
    context "DELETE to :destroy without javascript" do
      
      setup { delete :destroy, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :redirect
      should_redirect_to("Index") { user_time_entries_url(:user_id => users(:bob).id, :date => time_entries(:bob_timeflux_development_26_monday).date.to_s) }
      should_change("the number of time entries", :by => -1) { TimeEntry.count }
      should_set_the_flash_to "Time Entry deleted"
      
    end
    
    context "DELETE to :destroy with javascript" do
      
      setup { xhr :delete, :destroy, :user_id => users(:bob).id, :id => time_entries(:bob_timeflux_development_26_monday).id }
      
      should_respond_with :success
      should_change("the number of time entries", :by => -1) { TimeEntry.count }
      
      should "refresh time entries for the relevant day" do
        assert_select_rjs :replace_html, "Monday_time_entries_container"
      end
      
      should "update the day total hours field" do 
        assert_select_rjs :replace_html, "Monday_total" do
          assert_select "b", "0.0"
        end
      end
      
    end
    
    context "POST to :change_user for administrator" do
      
      setup { post :change_user, :user_id => users(:bob).id, :new_user_id => users(:bill).id, :date => @date.to_s }
      
      should_respond_with :redirect
      should_redirect_to("Index") { user_time_entries_url(:user_id => users(:bill).id, :date => @date.to_s) }
      
    end
    
    context "POST to :change_user for regular user" do
      
      setup {
        login_as :bill 
        post :change_user, :user_id => users(:bill).id, :new_user_id => users(:bob).id, :date => @date.to_s 
        }
      
      should_set_the_flash_to "Mind your own business"
      should_respond_with :redirect
      should_redirect_to("Index") { user_time_entries_url(:user_id => users(:bill).id, :date => @date.to_s) }
      
    end
    
  end
  
  context "User not logged in: " do
    
    context "GET to :index" do            
      setup { get :index }            
      should_redirect_to("Login page") { new_user_session_url }          
    end
    
    context "GET to :previous (Previous Week link)" do      
      setup { get :previous }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :next (Next Week link)" do      
      setup { get :next }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :new" do      
      setup { get :new }      
      should_redirect_to("Login page") { new_user_session_url }           
    end
    
    context "GET to :edit" do      
      setup { get :edit }      
      should_redirect_to("Login page") { new_user_session_url }                  
    end
    
    context "successful POST to :update" do      
      setup { put :update }              
      should_redirect_to("Login page") { new_user_session_url }      
     end
      
    context "unsuccessful POST to :update" do      
      setup { put :update }      
      should_redirect_to("Login page") { new_user_session_url }                          
    end
    
    context "POST to :update for locked time entries" do      
      setup { put :update }      
      should_redirect_to("Login page") { new_user_session_url }                  
    end
    
    context "DELETE to :destroy" do      
      setup { delete :destroy }      
      should_redirect_to("Login page") { new_user_session_url }      
    end
    
  end 
  
end