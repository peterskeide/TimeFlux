require 'test_helper'

class VacationsControllerTest < ActionController::TestCase
  
  def setup
    Configuration.instance.update_attribute(:activity_id, activities(:vacation).id)
  end

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end

    context "get index" do
      setup{ get :index }
      should_render_template :index
    end

    context "PUT to :update with new vacation entries" do
      setup { put :update, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"} }
      should_redirect_to("vacation index") { vacations_url(:date => "2009-08-01") }
      should "create vacation time_entries on the checked dates" do
        entry = TimeEntry.on_day(Date.civil(2009,8,18))
        assert_equal entry[0].hours, 7.5
      end
    end

    context "PUT to :update with removed vacation entries" do
      setup do
        TimeEntry.create(:user => users(:bob), :hours => 4, :date => Date.parse("2009-08-3"), :activity => activities(:vacation))
        put :update, :month => "2009-08-1", :user_id =>  users(:bob).id, :date => { }
      end
      should_redirect_to("vacation index") { vacations_url(:date => "2009-08-01") }
      should "remove unchecked vacation dates" do
        assert TimeEntry.on_day(Date.civil(2009,8,3)).empty?
      end
    end
  end

  context "Logged in as user Bill, trying to update bob´s vacations" do
    setup do
      login_as(:bill)
      post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"}
      should_set_the_flash_to(/No permission/i)
    end
  end
end
