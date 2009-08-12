
class MonthController < ApplicationController

  before_filter :check_authentication

  def index
    redirect_to(:action => 'week')
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
    setup_calender

    users = User.find(:all)
    start = Date.today.beginning_of_week + 56 #looking 8 weeks ahead
    weeks = []
    1..10.times { |i| weeks << start - (i * 7) }

    user_data = users.sort.collect do |user|
      [user.fullname ] + weeks.collect do |day|
        TimeEntry.for_user(user).between(day, (day + 6)).to_a.sum(&:hours)
      end
    end

    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name'] + weeks.collect { |d| "Week #{d.cweek}" } )
    respond_with_formatter @table, TestController, "Public time entries (incorrect data)"
  end

  def update_listing
    setup_month_view
    create_listing
    render :partial => 'listing_content', :locals => { :table => @table, :params => params }
  end

  def week
    setup_month_view
  end

  def update_week
    setup_month_view
    render :partial => 'week_content', :locals => { :day => @day, :user => @user, :activities_summary => @activities_summary }
  end

  private

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
