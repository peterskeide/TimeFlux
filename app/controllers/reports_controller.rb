Mime::Type.register 'application/pdf', :pdf
Mime::Type.register 'text/plain', :csv

require 'report_renderer'

require 'ruport'
require "ruport/util"
#require "ruport/extensions"

class ReportsController < ApplicationController

  before_filter :check_authentication

  def index
    @reports = self.send(:action_methods).delete("index").sort
  end

  def user

    @table = User.report_table(:all,
      :only       => %w[firstname lastname username email operative_status updated_at],
      :group      => "lastname")

    respond_to do |format|
      format.html
      format.pdf { send_data @table.to_pdf }
      format.csv { send_data @table.to_csv,{ :type => "	text/plain", :disposition  => "inline", :filename => "#user_report.csv" } }
    end

  end

  def test
    @table = Ruport::Data::Table.new :data => [[1,2,3], [3,4,5]],
      :column_names => %w[a b c]
    render :action => "show_table"
  end

  def hours
    users = User.find(:all)
    userdata = users.collect do |user|
      [user.fullname, user.login, user.email, user.hours_total]
    end

    table = Ruport::Data::Table.new( :data => userdata,
      :column_names => %w[Name Login Email Total] )
    @table = Grouping(table,:by => "Name")

    render :action => "show_table"
  end

  #TODO finnish
  def test_rendering
    table = Ruport::Data::Table.new :data => [[1,2,3], [3,4,5]],
      :column_names => %w[a b c]
    #send data ReportRenderer.render_pdf()
    #render :action => "show_table"
  end
end
