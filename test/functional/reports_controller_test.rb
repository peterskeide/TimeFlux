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
      should_redirect_to("Billing report") { "/reports/billing" }
    end

    context "accessing reports," do
 
      reports = [
        [:user, {}, %w{ html pdf csv text} ],
        [:summary, {}, %w{ html pdf csv text} ],
        [:activity, {}, %w{ html pdf csv text} ],
        [:billing, {}, %w{ html} ] #TODO pdf test fails??
      ]
      reports.each do |report, params, formats|
        context "on GET to :#{report} with params #{params}" do

          formats.each do |format|
            context "with format=#{format}" do
              setup { get report, {:format => format}.merge(params) }
              should_respond_with :success
              #should_respond_with_content_type(format.to_sym)
            end
          end
        end
      end
    end

    ['locked','billed'].each do |mark|
      context "marking hours as #{mark}" do
        setup do
          @time_entry = activities(:timeflux_development).time_entries.on_day( Date.new(2009,7,4) )[0]
          @billed_before = @time_entry.__send__(mark)
          post :mark_time_entries, :mark_as => mark,:month=>7, :year=>2009, :method => 'post'
        end
        should 'have billed=false initially' do
          assert ! @billed_before
        end

        should "change #{mark} to true" do
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