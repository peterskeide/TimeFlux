class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
  before_filter :check_parent_user, :except => :change_user
  before_filter :find_user, :except => :add_tag
         
  def index 
    @date = params[:date].blank? ? Date.today.beginning_of_week : Date.parse(params[:date]).beginning_of_week
    time_entries_for_week = @user.time_entries.between(@date, @date.end_of_week)
    @time_entries = MonthReview::TimeEntryArray.new(time_entries_for_week)
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
    hour_type = HourType.default
    @activity = Activity.find(params[:activity_id])
    @time_entry = TimeEntry.new(:date => @date, :activity_id => @activity.id, :hour_type_id => hour_type.id)
    @time_entries = @user.time_entries.on_day(@date).for_activity(@activity)
  end
   
  # TODO: implement support for tags 
  def create
    @time_entry = @user.time_entries.build(params[:time_entry])
    #if params[:tags].respond_to? :each
    #  params[:tags].each { |id, value| @time_entry.tags << Tag.find(id.to_i) if value == 'true'}
    #end
    if @time_entry.save
      @date = @time_entry.date
      calculate_day_and_week_totals
      @day_name = Date::DAYNAMES[@date.wday]
      @new_time_entry = TimeEntry.new(:date => @date, :activity_id => @time_entry.activity.id, :hour_type_id => HourType.default.id)
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
  
  # TODO: add support for tags  
  def update
    @time_entry = @user.time_entries.find(params[:id])
    #if params[:tags].respond_to? :each
    #  tags = []
    #  params[:tags].each { |id, value| tags << Tag.find(id.to_i) if value == 'true'}
    #  @time_entry.tags = tags
    #end
    if @time_entry.update_attributes(params[:time_entry])
      @date = @time_entry.date
      calculate_day_and_week_totals
      @day_name = Date::DAYNAMES[@date.wday]
      @new_time_entry = TimeEntry.new(:date => @date, :activity_id => @time_entry.activity.id, :hour_type_id => HourType.default.id)
    else
      @errors = @time_entry.errors.full_messages.join(', ') 
    end
  end
  
  def destroy
    @time_entry = @user.time_entries.find(params[:id])
    @time_entry.destroy
    @date = @time_entry.date
    calculate_day_and_week_totals
    @day_name = Date::DAYNAMES[@date.wday]
  end 
  
  def lock
    @start = Date.parse(params[:start_date])
    @end = Date.parse(params[:end_date])
    @user.time_entries.between(@start, @end).each { |te| te.update_attribute(:status, TimeEntry::LOCKED) }
    redirect_to user_month_review_url(:user_id => params[:user_id], :id => :calendar)
  end

  private
  
  def calculate_day_and_week_totals
    time_entries = @user.time_entries.for_activity(@time_entry.activity).between(@date.beginning_of_week, @date.end_of_week)
    time_entry_array = MonthReview::TimeEntryArray.new(time_entries)
    @day_sum = time_entry_array.for_date(@date).sum_hours
    @week_sum = time_entry_array.sum_hours
  end
  
  def find_user
    @user = User.find(params[:user_id])
  end
           
end