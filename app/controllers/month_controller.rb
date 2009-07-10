

class MonthController < ApplicationController

  #load 'test_controller.rb'

  before_filter :check_authentication

  def index
    redirect_to(:action => 'week')
  end

  def week
    setup_month_view
  end

  def month
    setup_month_view
  end

  def summary
    setup_month_view
  end

  def listing
    setup_month_view

    time_data = []
    @user.time_entries.between(@day,(@day >> 1) -1).sort.each do |t|
      time_data << [t.activity.name, t.hours, t.date, t.notes] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ["Activity name","Hours","Date","Notes"] )
    table.sort_rows_by!(["Date"])

    activities_data = @activities_summary.collect { |a| [a[:name],a[:hours]] }
    activities_data << ['Sum',@activities_summary.collect { |i| i[:hours] }.sum]

#    summary =  Ruport::Data::Group.new( :name => 'Summary',:data => activities_data,
#      :column_names => ['Activity name','Hours'] )

    @table = Grouping(table,:by => "Activity name", :order => :name)

    @summary = @table.summary(:name, :hours => lambda { |g| g.sigma(:Hours) },
                     :order => [:name] )


    #@table.sort_grouping_by! { |g| (g.name == 'Summary' ? 'h' : 'b') + g.name }

    respond_with_formatter @table, TestController, "Hour report for #{@user.fullname}"
  end

  private

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
