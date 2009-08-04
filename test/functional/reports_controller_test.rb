require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do

    setup do
      login_as(:bob)
    end

    # depends on controllers private function :action_methods which returns nil during tests
    context "on GET report index" do
      #setup { get :index }
      #should_respond_with :success
    end

    context "accessing reports," do

      reports = { :user => {},:activity => {}, :hours => { :month=>7, :year=>2009} }
      reports.each do |report, params|

        context "on GET to :#{report}" do

          context "with html" do
            setup { get report, {}.merge(params) }
            should_respond_with :success
            should_respond_with_content_type(:html)
            should_not_set_the_flash
          end

          context "with format=pdf" do
            setup { get report, {:format => 'pdf', :tag=> tags(:timeflux).id }.merge(params) }
            should_respond_with :success
            should_respond_with_content_type(:pdf)
          end

          context "with format=csv" do
            setup { get report, {:format => 'csv', :tag=> tags(:timeflux).id }.merge(params) }
            should_respond_with :success
            should_respond_with_content_type(:text)
          end

          context "with format=text" do
            setup { get report, {:format => 'text', :tag=> tags(:timeflux).id}.merge(params) }
            should_respond_with :success
            should_respond_with_content_type(:text)
          end
        end
      end
    end

    context 'on POST to :billing' do
      setup do
        time_entry = tags(:timeflux).activities.collect { |a| a.time_entries.on_day( Date.new(2009,7,1) )}.flatten[0]
        @billed_before = time_entry.billed

        post :hours, :month=>7, :year=>2009, :tag=>tags(:timeflux).id, :method => 'post'
      end
      should 'have billed=false initially' do
        assert ! @billed_before
      end
      
      should 'change billed to true' do
        time_entry = tags(:timeflux).activities.collect { |a| a.time_entries.on_day( Date.new(2009,7,1) )}.flatten[0]
        assert time_entry.billed
      end
    end
       
  end

  context 'Logged in as bill' do
    setup do
      login_as(:bill)
    end

    reports = [:user, :activity, :hours]
    reports.each do |report|
      context "on GET to :#{report}" do
        setup { get report }
        should_redirect_to("Time Entries") { "/time_entries" }
      end
    end
  end

  context "Not logged in" do
    reports = [:user, :activity, :hours]
    reports.each do |report|
      context "on GET to :#{report}" do
        setup { get report }
        should_redirect_to("Login page") { "/user_sessions/new" }
      end
    end    
  end

end