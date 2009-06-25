class TimeEntriesController < ApplicationController
  
  before_filter :check_authentication
    
  def index    
    @date = params[:date] ? Date.parse(params[:date]) : Date.today.beginning_of_week
    init_index(@date)
  end
  
  def previous
    @date = Date.parse(params[:date]).- 7
    init_index(@date)
    render :index
  end
  
  def next
    @date = Date.parse(params[:date]).+ 7
    init_index(@date)
    render :index
  end
  
  def new
    @activity = Activity.find_by_id(params[:activity][:activity_id])
    @user = @current_user
    @date = Date.parse(params[:date])
    @time_entries = []
    7.times { |i| @time_entries << @user.time_entries.create(:date => @date.+(i), :activity => @activity) }
    redirect_to :action => "edit", :id => @user.id, :activity_id => @activity.id, :date => @date
  end
   
  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Time entries successfully saved"
      redirect_to :action => "index", :date => params[:date]
    else
      @date = Date.parse(params[:date])
      activity_id = params[:activity_id].to_i
      @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
      render :edit
    end
  end
    
  def edit
    @user = User.find_by_id(params[:id])
    @date = Date.parse(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    @date = Date.parse(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
    @time_entries.each { |te| te.destroy }
    init_index(@date)
    render :index
  end
  
  private 
  
  # Encapsulates common code used by index, next, previous and destroy actions.
  # Initializes instance variables for the index view-template.
  # @activities is a map with keyset = names of activities that have
  # time entries for the current week/user, and value = array of time entries (always size == 7)
  def init_index(date)
    @user = @current_user
    monday = date.beginning_of_week
    time_entries = @user.time_entries.between(monday, monday.+(6))
    @activities = {}
    if time_entries
      activity_names = time_entries.collect { |te| te.activity.name }.uniq
      activity_names.each { |name| @activities[name] = [] }
      time_entries.sort.each { |te| @activities[te.activity.name]  << te } 
    end
    find_activities_for_time_entry
  end
  
  # Initializes an array of arrays [[ name, id ]] for use as select options in the view.
  # If the name of an activity in the user_and_default_activities array is present in 
  # the @activities map keyset, that activity will not be available as an option. 
  # The rationale is: An activity can only have one set of time entries per user per week. 
  def find_activities_for_time_entry
    user_and_default_activities = @user.activities + Activity.find_all_by_default_activity(true) 
    @activity_options = user_and_default_activities.collect { |a| @activities.keys.include?(a.name) ? nil : [ a.name, a.id ] }.compact
  end
  
  def find_time_entries_for_activity_and_date(activity_id, monday)
     @user.time_entries.for_activity(activity_id).between(monday, monday.+(6))
  end
    
end