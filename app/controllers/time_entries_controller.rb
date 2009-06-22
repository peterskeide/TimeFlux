class TimeEntriesController < ApplicationController
  
  before_filter :check_authentication
    
  def index    
    @date = Date.today
    prepare_view(@date)
  end
  
  def previous
    @date = Date.parse(params[:date]).- 7
    prepare_view(@date)
    render :index
  end
  
  def next
    @date = Date.parse(params[:date]).+ 7
    prepare_view(@date)
    render :index
  end
  
  def new
    @activity = Activity.find_by_id(params[:activity][:activity_id])
    @user = @current_user
    @date = Date.parse(params[:date]).beginning_of_week
    @time_entries = []
    7.times { |i| @time_entries << @user.time_entries.create(:date => @date.+(i), :activity => @activity) }
    render :edit
  end
   
  def update
    @user = User.find_by_id(params[:user][:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Time entries successfully saved"
      @date = Date.parse(params[:date]).beginning_of_week 
      prepare_view(@date)
      render :index
    else
      @date = Date.parse(params[:date]).beginning_of_week
      activity_id = params[:activity_id].to_i
      @time_entries = @user.time_entries.for_activity(activity_id).between(@date, @date.+(6))
      render :edit
    end
  end
    
  def edit
    @user = User.find_by_id(params[:id])
    @date = Date.parse(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = @user.time_entries.for_activity(activity_id).between(@date, @date.+(6))
  end
  
  def destroy
  end
  
  private 
  
  def prepare_view(date)
    find_activities
    monday = date.beginning_of_week
    time_entries = @user.time_entries.between(monday, monday.+(6))
    @activities = {}
    if time_entries
      activity_names = time_entries.collect { |te| te.activity.name }.uniq
      activity_names.each { |name| @activities[name] = [] }
      time_entries.sort.each { |te| @activities[te.activity.name]  << te } 
    end
  end
  
  def find_activities
    @user = @current_user
    activities = @user.activities + Activity.find_all_by_default_activity(true) 
    @activity_options = activities.collect { |a| [ a.name, a.id ] }
  end
    
end