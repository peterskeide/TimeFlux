Mime::Type.register 'application/pdf', :pdf
#Mime::Type.register 'text/plain', :csv

require 'report_renderer'
require 'test_controller'

require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication

  def index
    @reports = self.__send__(:action_methods).delete("index").sort
  end

  def activity
     if params[:active] then
      activities = Activity.find(:all, :conditions => { :active => params[:active] == 'true'} )
    else
      activities = Activity.find(:all)
    end
    
    activity_data = activities.collect { |a|
      [a.name, a.tags.to_s, a.active]
    }
    @table = Ruport::Data::Table.new( :data => activity_data,
      :column_names => ['Activity name', 'Tags', 'Active'] )
    respond_with_formatter@table, TestController, "Activity report"
  end

  def user
    if params[:status] then
      users = User.find(:all, :conditions => ["operative_status=? ", params[:status]] )
    else
      users = User.find(:all)
    end
        
    user_data = users.collect { |u|
      [u.fullname, u.login, u.email, u.operative_status]
    }
    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name', 'Login', 'E-mail', 'Status'] )
    respond_with_formatter @table, TestController, "User report"
  end

  def tag
    setup_calender
    
    @tag_types = TagType.find(:all)
    @tag_type = TagType.find(params[:tag_type]) if params[:tag_type]
    @tag = Tag.find(params[:tag]) if params[:tag]
    
    @tags = @tag_type.tags if @tag_type

    if @tag
      report_data = []
      @tag.activities.each do |activity|

        activity.time_entries.between(@day,@day >> 1).each do |t|
          report_data << [activity.name, t.hours, t.user.fullname, t.notes] if t.hours > 0
        end
      end
      table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity name', 'Hours', 'Consultant', 'Notes'])
    
      @table = Grouping(table,:by => "Activity name")
      respond_with_formatter @table, TestController, "Hour report for #{@tag.name}"
    end
  end

  def hours
    setup_calender
     
    @selected_user = User.find(params[:user]) if params[:user]
    @selected_user ||= current_user_session.user

    # Content of selects
    @users = User.find(:all)

    time_entries = @selected_user.time_entries.between(@day.beginning_of_month, @day.end_of_month)

    time_data = time_entries.collect { |e| [e.activity.name, e.hours, e.date, e.notes] }
    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ['Activity name', 'Date', 'Hours', 'Notes'])

    @table = Grouping(table,:by => "Activity name")
    respond_with_formatter @table, TestController, "Hour report for user: #{@selected_user.fullname}"
  end

private

  def setup_calender
    @day = first_in_month(params[:year], params[:month])
    @selected_year = @day.year
    @selected_month = @day.month
    
    @years = (2007..Date.today.year).to_a.reverse
    @months = []    
    month_names = %w{ January Febrary March April May June July August September October November December}
    month_names.each_with_index { |name, i| @months << [ i+1, name ] }
  end
  
  def first_in_month(year, month)
    year ||= Date.today.year
    month ||= Date.today.month
    return Date.new(year.to_i, month.to_i, 1)
  end

  def x_test_only_grouping
    users = User.find(:all)
    userdata = users.collect do |user|
      [user.fullname, user.login, user.email, user.hours_total]
    end

    table = Ruport::Data::Table.new( :data => userdata,
      :column_names => %w[Name Login Email Total] )
    @table = Grouping(table,:by => "Name")
    respond_with_formatter_and_html @table, TestController, "Test report 1"
  end


  def x_test_normal
    @table = Ruport::Data::Table.new :data => [[1,2,3], [3,4,5]],
      :column_names => %w[a b c]
    respond_with_formatter_and_html @table, TestController, "Test report 2"
  end

  #Really private method below

 def respond_with_formatter(data, formatter, title="report")
    respond_to do |format|
      format.html{@title = title; @table = data}
      format.pdf { send_data formatter.render_pdf(:data => data, :title => title),
        { :type => "	application/pdf", :disposition  => "inline", :filename => "#{title}.pdf" } }
      format.csv { send_data formatter.render_csv(:data => data, :title => title),
        { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.csv" } }
      format.text { send_data formatter.render(:text, :data => data, :title => title),
        { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.txt" } }
    end
  end
  
  def respond_with_formatter_and_html(data, formatter, title="report")
    respond_to do |format|
      format.html{ @title = title; @params = params; @table = data; render :action => "show_table" }
      format.pdf { send_data formatter.render_pdf(:data => data, :title => title),
        { :type => "	application/pdf", :disposition  => "inline", :filename => "#{title}.pdf" } }
      format.csv { send_data formatter.render_csv(:data => data, :title => title),
        { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.csv" } }
      format.text { send_data formatter.render(:text, :data => data, :title => title),
        { :type => "	text/plain", :disposition  => "inline", :filename => "#{title}.txt" } }
    end
  end

end