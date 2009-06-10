require 'date_extensions'

class WeekEntriesController < ApplicationController
  
  before_filter :check_authentication 
     
  def index 
    @date = Date.today
    prepare_view(@date)
  end
  
  def next
    @date = Date.parse(params[:date]).+ 7
    prepare_view(@date)   
    render :index
  end
  
  def previous
    @date = Date.parse(params[:date]).- 7
    prepare_view(@date)
    render :index
  end
  
  def new
    @activities = Activity.find(:all)
    @week_entry = WeekEntry.new
    date = Date.parse(params[:date])
    @week = Date.week_of_date(date)
    @week_entry.week_number= @week[:thursday].cweek
    @week_entry.year= @week[:thursday].year
    7.times { |i| @week_entry.time_entries.build(:date => @week.values.sort[i]) }
  end
  
  def create
    @week_entry = WeekEntry.new(params[:week_entry])
    activity = Activity.find_by_id(params[:activity][:id])
    @week_entry.activity = activity
    @week_entry.user = @current_user    
    if @week_entry.save
      flash[:notice] = "Time entries successfully saved for activity"
      render_week_for_date @week_entry.time_entries.sort[0].date
    else
      @activities = Activity.find(:all)
      @week = Date.week_of_date(@week_entry.time_entries[0].date)
      render :new
    end
  end
  
  def edit
    @week_entry = WeekEntry.find(params[:id])
  end
  
  def update
    @week_entry = WeekEntry.find(params[:id])
    if (@week_entry.update_attributes(params[:week_entry]))
      flash[:notice] = "Week entry successfully updated"
      render_week_for_date @week_entry.time_entries.sort[0].date
    else
      render :edit
    end
  end
  
  def destroy
    @week_entry = WeekEntry.find(params[:id])
    @date = @week_entry.time_entries.sort[0].date
    @week_entry.destroy
    prepare_view(@date)
    render :index
  end
  
  private
  
  def find_activities
    @activities = Activity.find_by_user_id_and_default(@current_user.id, true)
  end
  
  def prepare_view(date)
    year = date.year
    @week_number = date.cweek
    @week_entries = WeekEntry.find_all_by_year_and_week_number_and_user_id(year, @week_number, @current_user.id)
  end
  
  def render_week_for_date(date)
    @date = date
    prepare_view(@date)
    render :index
  end
  
end