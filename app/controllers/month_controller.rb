
class MonthController < ApplicationController

  before_filter :check_authentication

  def index
    redirect_to(:action => 'calender')
  end

  def month
    setup_calender
    @user=current_user_session.user
    @activities_summary = create_activity_summary(@day, @user)
  end


  def listing
    setup_calender
    @user=current_user_session.user
    @table = create_listing(@day)
    respond_with_formatter @table, TestController, "Hour report for #{@user.fullname}"
  end

  def shared

    @shared_activities = Activity.shared(true)

    if params[:activity] && params[:activity] != ""
      activity = Activity.find(params[:activity])
    else
      activity = @shared_activities[0]
    end
    report = create_shared_report(activity)

    respond_with_formatter report, TestController, "Public time entries"
  end

  def update_shared
    activity = Activity.find(params[:activity_id])
    table = create_shared_report(activity)
    render :partial => 'table', :locals => { :table => table }
  end

  def update_listing
    @day = Date.new(params[:calender]["date(1i)"].to_i, params[:calender]["date(2i)"].to_i,1)
    @user = current_user_session.user
    render :partial => 'listing_content', :locals => { :table => create_listing(@day,@user), :params => params }
  end

  def calender
    setup_calender
    @user=current_user_session.user
    @activities_summary = create_activity_summary(@day,@user)
  end

  def update_calender

    day = Date.new(params[:calender]["date(1i)"].to_i, params[:calender]["date(2i)"].to_i,1)
    @user = current_user_session.user
    activities = []
    @user.time_entries.between(day,day.at_end_of_month).each do |t|
      activities << t.activity unless activities.include? t.activity
    end
    activities_summary = activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(@user).between(day,day.at_end_of_month).sum(:hours) }
    end
    render :partial => 'calender_content', :locals => { :day => day, :user => @user, :activities_summary => activities_summary }
  end

  private

  def create_shared_report(activity)
    start = Date.today.beginning_of_week + 56 #looking 8 weeks ahead
    weeks = []
    1..10.times { |i| weeks << start - (i * 7) }
    weeks.reverse!

    user_data = User.all.sort.collect do |user|
      [user.fullname ] + weeks.collect do |day|
        TimeEntry.for_user(user).for_activity(activity).between(day, (day + 6)).to_a.sum(&:hours)
      end
    end

    return Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name'] + weeks.collect { |d| "Week #{d.cweek}" } )
  end


  def create_listing(day, user=current_user_session.user)
        time_data = []
    user.time_entries.between(day,(day >> 1) -1).sort.each do |t|
      time_data << [t.activity.customer_project_name, t.hours, t.date, t.notes] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ["Activity name","Hours","Date","Notes"] )
    table.sort_rows_by!(["Date"])

    return Grouping(table,:by => "Activity name", :order => :name)
  end



end
