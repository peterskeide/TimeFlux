require 'test_helper'

class VacationsControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end

    context "get index" do
      setup{ get :index }
      should_render_template :index
    end

    context "set vacation" do
      setup { post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id,
        :date => { "2009-08-17" => "1", "2009-08-18"=>"1", "2009-08-19"=>"1"} }
      should_redirect_to("vacation page page") { "vacations/index?date=2009-08-01" }
      should "create vacation time_entries on the checked dates" do
        entry = TimeEntry.on_day(Date.civil(2009,8,18))
        assert_equal entry[0].hours, 7.5
      end
    end

    context "remove vacation" do
      setup do
        TimeEntry.create(:user => users(:bob), :hours => 4, :date => Date.parse("2009-08-3"), :activity => activities(:vacation))
        post :set_vacation, :month => "2009-08-1", :user_id =>  users(:bob).id, :date => { }
      end
      should_redirect_to("vacation page page") { "vacations/index?date=2009-08-01" }
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
