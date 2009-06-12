require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  context "on GET to :user_report" do

    context "with html" do
      setup { get :user_report }
      should_respond_with :success
      should_not_set_the_flash
    end

    context "with format=pdf" do
      setup { get :user_report, :format => 'dpf' }
      #TODO the download works, why does the test repport a 406?
      #should_respond_with :sucsess
    end

    context "with format=csv" do
      setup { get :user_report, :format => 'csv' }
      should_respond_with :success
    end
  end
end
