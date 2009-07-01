require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  def setup
    login_as(:bob)
  end

  context "Accessing reports," do

    reports = { :user => {},:activity => {}, :billing => { :month=>7, :year=>2009},:hours => {} }
 
    reports.each do |report, params|
      context "on GET to #{report.to_s}" do

        context "with html" do
          setup { get report }
          should_respond_with :success
          should respond_with_content_type(:html)
          should_not_set_the_flash
        end

        context "with format=pdf" do
          setup { get report, {:format => 'pdf', :tag=> tags(:timeflux).id }.merge(params) }
          should_respond_with :success
          should respond_with_content_type(:pdf)
        end

        context "with format=csv" do
          setup { get report, {:format => 'csv', :tag=> tags(:timeflux).id }.merge(params) }
          should_respond_with :success
          should respond_with_content_type(:csv)
        end

        context "with format=text" do
          setup { get report, {:format => 'text', :tag=> tags(:timeflux).id}.merge(params) }
          should_respond_with :success
          should respond_with_content_type(:text)
        end

      end
    end
  end
end
