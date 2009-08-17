require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    
    setup do
      login_as(:bob)
      @tag_type_id = tag_types(:project).id
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end

    context "on GET report index" do
      setup { get :index }
      should_redirect_to("Hours report") { "/reports/hours" }
    end

    context "accessing reports," do
 
      reports = [
        [:user, {} ],
        [:summary, {} ],
        [:activity, {} ],
        [:hours, {:month=>7, :year=>2009, :billed => false} ],
        [:hours, {:month=>7, :year=>2009, :grouping => 'Activity', :tag_type_id => @tag_type_id} ]
      ]
      reports.each do |report, params|

        context "on GET to :#{report} with params #{params}" do

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

    ['locked','billed'].each do |mark|
      context "marking hours as #{mark}" do
        setup do
          @time_entry = tags(:timeflux).activities.collect { |a| a.time_entries.on_day( Date.new(2009,7,1) )}.flatten[0]
          @billed_before = @time_entry.__send__(mark)

          post :mark_time_entries, :mark_as => mark,:month=>7, :year=>2009, :tag=>tags(:timeflux).id, :method => 'post'
        end
        should 'have billed=false initially' do
          assert ! @billed_before
        end

        should 'change billed to true' do
          @time_entry.reload
          assert @time_entry.__send__(mark)
        end
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