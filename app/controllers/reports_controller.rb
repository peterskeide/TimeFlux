
require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    redirect_to(:action => 'hours')
    #  @reports = self.__send__(:action_methods).delete("index").sort
  end

    # Currently not in use
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

  def user
    setup_calender
    if params[:status] then
      users = User.find(:all, :conditions => ["operative_status=? ", params[:status]] )
    else
      users = User.find(:all)
    end

    start = Date.today.beginning_of_week
    weeks = []
    1..10.times { |i| weeks << start - (i * 7) }

    user_data = users.sort.collect do |user|
      [user.fullname ] + weeks.collect do |day|
        TimeEntry.for_user(user).between(day, (day + 6)).to_a.sum(&:hours)
      end
    end
    
    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name'] + weeks.collect { |d| "Week #{d.cweek}" } )
    respond_with_formatter @table, TestController, "User report"
  end

  def hours
    setup_calender
    activities = setup_hours_form
    user = User.find(params[:user]) if params[:user] && params[:user] != ""

    time_entries = TimeEntry.search( @from_day, @to_day, activities, user, params[:billed] )

    report_data = []
    time_entries.each do |t|
      report_data << [ t.activity.name, t.date, t.hours, t.user.fullname, t.locked, t.billed, t.counterpost, t.notes ] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity', 'Date', 'Hours', 'Consultant', 'Locked', 'Billed', 'Counterpost', 'Notes'])

    if params[:sort_by] && params[:sort_by] != ""
      table.sort_rows_by!( params[:sort_by].split(' - ') )
    end
    

    if params[:grouping] && params[:grouping] != ""
      table = Grouping(table,:by => params[:grouping])
    end

    title = "Hour report"
    respond_with_formatter table, TestController, title
  end

  def summary
    setup_calender
    activities = setup_hours_form

    time_entries = TimeEntry.search( @from_day, @to_day, activities )

    data_set = time_entries.group_by(&:activity).collect do |activity, time_entries|
      [activity.name, time_entries.sum(&:hours)]
     end

    table = Ruport::Data::Table.new( :data => data_set,
      :column_names => ['Activity', 'hours'])

    respond_with_formatter table, TestController, activities
  end

  def mark_time_entries
    if params[:method] == 'post'
      setup_calender
      activities = setup_hours_form
      user = User.find(params[:user]) if params[:user] && params[:user] != ""
      time_entries = TimeEntry.search(@from_day, @to_day, activities, user, params[:billed])
      if params[:mark_as] == 'billed'
        TimeEntry.mark_as_billed(time_entries)
      elsif params[:mark_as] == 'locked'
        TimeEntry.mark_as_locked(time_entries)
      end
    end
    redirect_to( params.merge( {:action => 'hours'}) )
  end

  def update_hours_form
    if request.xhr?
      setup_calender
      setup_hours_form
      render :partial => 'hours_form', :locals => { :params => params, :tag_type => @tag_type, :years => @years, :months => @months }
    end
  end

  private 

  def setup_hours_form
    params[:month] ||= @day.month
    
    @from_day = @day
    @to_day = (@day >> 1) -1
    case params[:days]
    when '1..15' then  @to_day = @day + 14
    when '16..31' then @from_day = @day + 15
    end

    if params[:tag_type_id] && params[:tag_type_id] != ""
      @tag_type = TagType.find(params[:tag_type_id])
      return @tag_type.activities
    end

    if params[:tag] && params[:tag] != ""
      return Tag.find(params[:tag]).activities
    end
    

  end

end