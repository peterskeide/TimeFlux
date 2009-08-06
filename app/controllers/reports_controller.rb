
require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    redirect_to(:action => 'hours')
    #  @reports = self.__send__(:action_methods).delete("index").sort
  end

  # Marks hours as billed on :POST
  def hours
    setup_calender
    activities = setup_hours_form

    user = User.find(params[:user]) if params[:user] && params[:user] != ""
    
    time_entries = TimeEntry.search(@day, activities, user, params[:billed])

    if params[:method] == 'post' 
      TimeEntry.mark_as_billed(time_entries)
    end

    report_data = []
    time_entries.each do |t|
      report_data << [t.activity.name, t.date, t.hours, t.user.fullname, t.locked, t.billed, t.notes] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity', 'Date', 'Hours', 'Consultant', 'Locked', 'Billed', 'Notes'])
    table.sort_rows_by!(["Date"])

    if params[:grouping] && params[:grouping] != ""
      table = Grouping(table,:by => params[:grouping])
    end

    title = "Hour report"
    respond_with_formatter table, TestController, title
  end


  def update_hours_form
    setup_calender
    setup_hours_form
    render :partial => 'hours_form', :locals => { :params => params, :tag_type => @tag_type, :years => @years, :months => @months }
  end


  #deprecated....
  def activity
     if params[:active] then
      activities = Activity.find(:all, :conditions => { :active => params[:active] == 'true'} )
    else
      activities = Activity.find(:all)
    end
    
    activity_data = activities.sort.collect { |a|
      [a.name, a.tags.join(', '), a.active]
    }
    @table = Ruport::Data::Table.new( :data => activity_data,
      :column_names => ['Activity name', 'Tags', 'Active'] )
    respond_with_formatter@table, TestController, "Activity report"
  end

  #deprecated....
  def user
    if params[:status] then
      users = User.find(:all, :conditions => ["operative_status=? ", params[:status]] )
    else
      users = User.find(:all)
    end
        
    user_data = users.sort.collect { |u|
      [u.fullname, u.login, u.email, u.operative_status]
    }
    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name', 'Login', 'E-mail', 'Status'] )
    respond_with_formatter @table, TestController, "User report"
  end

  private 
  
  def setup_hours_form
    params[:month] ||= @day.month

    if params[:tag_type_id] && params[:tag_type_id] != ""
      @tag_type = TagType.find(params[:tag_type_id])
      return @tag_type.activities
    end

    if params[:tag] && params[:tag] != ""
      return Tag.find(params[:tag]).activities
    end
  end

end