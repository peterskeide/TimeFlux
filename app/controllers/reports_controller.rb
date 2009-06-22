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
      [a.name, a.category.name, a.active]
    }
    @table = Ruport::Data::Table.new( :data => activity_data,
      :column_names => ['Activity name', 'Category', 'Active'] )
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

  def week_entries
    user = current_user_session.user
    week_data = user.week_entries.collect do |week_entry|
      [week_entry.year, week_entry.week_number, week_entry.activity.name, week_entry.hours]
    end
    table = Ruport::Data::Table.new( :data => week_data,
      :column_names => ['Year', 'Week number', 'Activity name', 'Hours'])
    @table = Grouping(table,:by => "Year")
    respond_with_formatter_and_html @table, TestController, "Week entries report"
  end

  def hours
    
    @selected_user = User.find(params[:user]) if params[:user]
    @selected_user ||= current_user_session.user
    day = get_month(params[:year], params[:month])
    @selected_year = day.year
    @selected_month = day.month
    
    # Content of selects
    @users = User.find(:all)
    @years = (2007..Date.today.year).to_a.reverse
    @months = []    
    month_names = %w{ January Febrary March April May June July August September October November December}
    month_names.each_with_index { |name, i| @months << [ i+1, name ] }
    
    time_entries = @selected_user.time_entries.between(day.beginning_of_month, day.end_of_month)

    time_data = time_entries.collect { |e| [e.week_entry.activity.name, e.hours, e.date, e.notes] }
    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ['Activity name', 'Date', 'Hours', 'Notes'])

    @table = Grouping(table,:by => "Activity name")

    respond_with_formatter @table, TestController, "Hours report"
      
  end

private

  def get_month(year, month)
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