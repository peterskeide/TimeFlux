class TimeEntriesController < ApplicationController
  
  before_filter :check_authentication
    
  def index    
    @date = params[:date]? Date.parse(params[:date]) : Date.today
    prepare_index(@date)
  end
  
  def previous
    @date = Date.parse(params[:date]).- 7
    prepare_index(@date)
    render :index
  end
  
  def next
    @date = Date.parse(params[:date]).+ 7
    prepare_index(@date)
    render :index
  end
  
  def new
    @activity = Activity.find_by_id(params[:activity][:activity_id])
    @user = @current_user
    @date = monday_in_week_of_given_date(params[:date])
    @time_entries = []
    7.times { |i| @time_entries << @user.time_entries.create(:date => @date.+(i), :activity => @activity) }
    render :edit
  end
   
  def update
    @user = User.find_by_id(params[:user][:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Time entries successfully saved"
      redirect_to :action => "index", :date => params[:date]
    else
      @date = monday_in_week_of_given_date(params[:date])
      activity_id = params[:activity_id].to_i
      @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
      render :edit
    end
  end
    
  def edit
    @user = User.find_by_id(params[:id])
    @date = monday_in_week_of_given_date(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    @date = monday_in_week_of_given_date(params[:date])
    activity_id = params[:activity_id].to_i
    @time_entries = find_time_entries_for_activity_and_date(activity_id, @date)
    @time_entries.each { |te| te.destroy }
    prepare_index(@date)
    render :index
  end
  
  private 
  
  # Encapsulates common code used by index, next and previous actions.
  # Initializes instance variables for the index view-template.
  def prepare_index(date)
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
  
  def find_time_entries_for_activity_and_date(activity_id, monday)
     @user.time_entries.for_activity(activity_id).between(monday, monday.+(6))
  end
  
  def monday_in_week_of_given_date(date)
    Date.parse(date).beginning_of_week
  end
    
end