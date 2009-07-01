Mime::Type.register 'application/pdf', :pdf

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

  def listing
    setup_calender
    user = current_user_session.user
      time_data = []
      data =[]
      user.time_entries.between(@day,(@day >> 1) -1).each do |t|
        time_data << [t.activity.name, t.hours, t.date, t.notes] if t.hours > 0
        data << {"activity_name" =>t.activity.name, "hours" => t.hours, "date" => t.date, "notes" => t.notes} if t.hours > 0
    end
    headers = ["activity_name","hours","date","notes"]

    table = Ruport::Data::Table.new( :data => time_data,
          :column_names => headers.collect { |h| h.capitalize.gsub('_',' ') } )
    table.sort_rows_by!(["date"])

    @table = Grouping(table,:by => "Activity name")
    respond_with_formatter @table, TestController, "Hour report for #{user.fullname}"
  end

  private

  def setup_month_view
    setup_calender
    @last_in_month = (@day >> 1) -1
    @user = current_user_session.user
    @activities = []
      @user.time_entries.between(@day,@day >> 1).each { |t|
        @activities << t.activity unless @activities.include? t.activity
      }
  end

end
