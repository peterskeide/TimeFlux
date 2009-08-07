class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication
    
  def index    
    @date = params[:date] ? Date.parse(params[:date]).beginning_of_week : Date.today.beginning_of_week
    init_time_entries_and_activities
    find_activity_options
  end
  
  def create_multiple
    activity = Activity.find_by_id(params[:activity][:activity_id])
    @date = Date.parse(params[:date])
    @time_entries = []
    7.times { |i| @time_entries << @current_user.time_entries.create(:date => @date.+(i), :activity => activity) }
    render :edit_multiple
  end
   
  def update_multiple
    begin
      params[:time_entry].each do |id, attrs|
        time_entry = TimeEntry.find_by_id(id)
        time_entry.update_attributes!(attrs)
      end
      flash[:notice] = "Time entries successfully updated"
      redirect_to time_entries_url(:date => params[:date])
    rescue Exception => e
      flash[:error] = e.message
      @date = Date.parse(params[:date])
      @time_entries = TimeEntry.find(params[:time_entry].keys)
      render :edit_multiple
    end 
  end
    
  def edit_multiple
    #if request.post?
      @date = Date.parse(params[:date])
      @time_entries = TimeEntry.find(params[:ids])
    #end
  end
  
  def grid_edit
    if request.post?
      @date = Date.parse(params[:date])
      init_time_entries_and_activities 
    end
  end
  
  def destroy_multiple
    time_entries = TimeEntry.find(params[:ids])
    if time_entries.any? {|e| e.locked}
      flash[:error] = "Week contain time entries which are locked"
    else
      TimeEntry.delete_all(["id IN (?)", params[:ids]])
    end
    redirect_to time_entries_url(:date => params[:date])
  end
  
  private
    
  def init_time_entries_and_activities
    @time_entries = @current_user.time_entries.between(@date, @date.+(6))
    @activities = @time_entries.collect { |te| te.activity }.uniq
  end
  
  # Initializes an array of arrays [[ name, id ]] for use as select options in the view.
  # If the name of an activity in the user_and_default_activities array is present in 
  # the @activities map keyset, that activity will not be available as an option. 
  # The rationale is: An activity can only have one set of time entries per user per week. 
  def find_activity_options
    user_and_default_activities = ( @current_user.activities + Activity.find_all_by_default_activity(true) ).uniq
    @activity_options = user_and_default_activities.collect { |a| @activities.include?(a) ? nil : [ a.name, a.id ] }.compact
  end
      
end