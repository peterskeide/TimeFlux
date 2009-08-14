
class MonthController < ApplicationController

  before_filter :check_authentication

  def index
    redirect_to(:action => 'calender')
  end

  def month
    setup_month_view
  end

  def summary
    setup_month_view
  end

  def listing
    setup_month_view
    create_listing
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

    respond_with_formatter report, TestController, "Shared time entries"
  end

  def update_shared
    activity = Activity.find(params[:activity_id])
    table = create_shared_report(activity)
    render :partial => 'table', :locals => { :table => table }
  end

  def update_listing
    setup_month_view
    create_listing
    render :partial => 'listing_content', :locals => { :table => @table, :params => params }
  end

  def calender
    setup_month_view
  end

  def update_calender

    day = Date.new(params[:calender]["date(1i)"].to_i, params[:calender]["date(2i)"].to_i,1)
    last_in_month = (day >> 1) -1
    user = current_user_session.user
    activities = []
    user.time_entries.between(day,last_in_month).each do |t|
      activities << t.activity unless activities.include? t.activity
    end
    activities_summary = activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(user).between(day,last_in_month).sum(:hours) }
    end
    render :partial => 'calender_content', :locals => { :day => day, :user => user, :activities_summary => activities_summary }

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


  def create_listing
        time_data = []
    @user.time_entries.between(@day,(@day >> 1) -1).sort.each do |t|
      time_data << [t.activity.name, t.hours, t.date, t.notes] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ["Activity name","Hours","Date","Notes"] )
    table.sort_rows_by!(["Date"])

    activities_data = @activities_summary.collect { |a| [a[:name],a[:hours]] }
    activities_data << ['Sum',@activities_summary.collect { |i| i[:hours] }.sum]

    @table = Grouping(table,:by => "Activity name", :order => :name)

    @summary = @table.summary(:name, :hours => lambda { |g| g.sigma(:Hours) },
                     :order => [:name] )
  end

  def setup_month_view
    setup_calender
    @last_in_month = (@day >> 1) -1
    @user = current_user_session.user
    @activities = []
    @user.time_entries.between(@day,@last_in_month).each do |t|
      @activities << t.activity unless @activities.include? t.activity
    end
    @activities_summary = @activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(@user).between(@day,@last_in_month).sum(:hours) }
    end
  end

end
