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
    @user = User.find_by_id(params[:id])
    @date = Date.parse(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = @user.time_entries.for_activity(activity_id).between(@date, @date.+(6))
    @time_entries.each { |te| te.destroy }
    prepare_view(@date)
    render :index
  end
  
  private 
  
  def prepare_view(date)
    @user = @current_user
    monday = date.beginning_of_week
    time_entries = @user.time_entries.between(monday, monday.+(6))
    @activities = {}
    if time_entries
      activity_names = time_entries.collect { |te| te.activity.name }.uniq
      activity_names.each { |name| @activities[name] = [] }
      time_entries.sort.each { |te| @activities[te.activity.name]  << te } 
    end
    find_activities
  end
  
  # Initializes an array of arrays [ name, id ] for use as select options in the view.
  # If the name of an activity in the user_and_default_activities array is present in 
  # the @activities map keyset, that activity will not be available as an option. 
  # The rationale is: You can create time entries for an activity once per week. 
  def find_activities
    user_and_default_activities = @user.activities + Activity.find_all_by_default_activity(true) 
    @activity_options = user_and_default_activities.collect { |a| @activities.keys.include?(a.name) ? nil : [ a.name, a.id ] }.compact
  end
    
end