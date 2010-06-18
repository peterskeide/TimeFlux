# TODO: add support for tags

class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
  before_filter :check_parent_user, :except => :change_user
  before_filter :find_user
         
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date]).beginning_of_week
    time_entries_for_week = @user.time_entries.between(@date, @date.end_of_week)
    @time_entries = MonthReview::TimeEntryArray.new(time_entries_for_week)
    @selectable_activities = @user.remaining_activities(@time_entries.uniq_activities)
  end
  
  def change_user
    if @current_user.admin
      redirect_to user_time_entries_url(:user_id => params[:new_user_id], :date => params[:date])
    else
      flash[:error] = "Mind your own business"
      redirect_to user_time_entries_url(@current_user, :date => params[:date])
    end
  end
  
  def new
    @date = Date.parse(params[:date])
    @activity = Activity.find(params[:activity_id])
    @time_entries = @user.time_entries.on_day(@date).for_activity(@activity) 
    @time_entry = TimeEntry.new(:date => @date, :activity_id => @activity.id, :hour_type_id => HourType.default.id)
  end
  
  def new_activity
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date]).beginning_of_week
    @activity = Activity.find(params[:activity_id])
    @sum_per_day = { 'Monday' => 0, 'Tuesday' => 0, 'Wednesday' => 0, 'Thursday' => 0, 'Friday' => 0, 'Saturday' => 0, 'Sunday' => 0 }
  end
   
  def create
    @time_entry = @user.time_entries.build(params[:time_entry])
    if @time_entry.save
      @new_time_entry = TimeEntry.new(:date => @time_entry.date, :activity_id => @time_entry.activity.id, :hour_type_id => HourType.default.id)
    else
      @errors = @time_entry.errors.full_messages.join(', ')         
    end
  end
  
  def edit
    @time_entry = @user.time_entries.find(params[:id])
  end
  
  def cancel_edit
    date = Date.parse(params[:date])
    @activity = Activity.find(params[:activity_id])
    @time_entry = TimeEntry.new(:date => date, :activity_id => @activity.id, :hour_type_id => HourType.default.id)
  end
  
  def update
    @time_entry = @user.time_entries.find(params[:id])
    if @time_entry.update_attributes(params[:time_entry])
      @new_time_entry = TimeEntry.new(:date => @time_entry.date, :activity_id => @time_entry.activity.id, :hour_type_id => HourType.default.id)
    else
      @errors = @time_entry.errors.full_messages.join(', ') 
    end
  end
  
  def refresh_totals
    @date = Date.parse(params[:date])
    @day_name = Date::DAYNAMES[@date.wday]
    @activity = Activity.find(params[:activity_id])
    time_entries = @user.time_entries.for_activity(@activity).between(@date.beginning_of_week, @date.end_of_week)
    time_entry_array = MonthReview::TimeEntryArray.new(time_entries)
    @day_sum = time_entry_array.for_date(@date).sum_hours
    @week_sum = time_entry_array.sum_hours
  end
  
  def destroy
    @time_entry = @user.time_entries.find(params[:id])
    @time_entry.destroy
    @no_more_time_entries = @user.time_entries.on_day(@time_entry.date).for_activity(@time_entry.activity).empty? # Optimize this!
  end 
  
  def lock
    @start = Date.parse(params[:start_date])
    @end = Date.parse(params[:end_date])
    @user.time_entries.between(@start, @end).each { |te| te.update_attribute(:status, TimeEntry::LOCKED) }
    redirect_to user_month_review_url(:user_id => params[:user_id], :id => :calendar)
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end
           
end