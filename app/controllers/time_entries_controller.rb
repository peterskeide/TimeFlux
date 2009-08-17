class TimeEntriesController < ApplicationController
    
  before_filter :check_authentication, :check_admin_if_new_user_id
    
  def index
    @user = User.find(params[:user_id])
    @date = params[:date] ? Date.parse(params[:date]).beginning_of_week : Date.today.beginning_of_week
    init_time_entries_and_activities
    find_activity_options
  end
  
  def create_multiple
    activity = Activity.find_by_id(params[:activity][:activity_id])
    @date = Date.parse(params[:date])
    @time_entries = []
    user = User.find(params[:user_id].to_i)
    7.times { |i| @time_entries << user.time_entries.create(:date => @date.+(i), :activity => activity) }
    render :edit_multiple
  end
   
  def update_multiple
    begin
      params[:time_entry].each do |id, attrs|
        time_entry = TimeEntry.find_by_id(id)
        time_entry.update_attributes!(attrs) unless time_entry.locked
      end
      flash[:notice] = "Time entries successfully updated"
      redirect_to user_time_entries_url(:user_id => params[:user_id], :date => params[:date])
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

  def create
    original = TimeEntry.find params[:original_time_entry]
    time_entry = TimeEntry.new( params[:time_entry].merge({:user => @current_user, :counterpost => true}) )
    time_entry.hours = time_entry.hours - original.hours
    if time_entry.save
      flash[:notice] = "Counterpost successfully created"
    else
      flash[:error] = time_entry.errors.full_messages.to_s
    end
    redirect_to user_time_entries_url(:user_id => params[:user_id], :date => params[:time_entry][:date])
  end

  def destroy
    time_entry = TimeEntry.find params[:id]
    if time_entry.destroy
      flash[:notice] = "Counterpost was removed"
    else
      flash[:error] = time_entry.errors.full_messages.to_s
    end
    redirect_to user_time_entries_url(:user_id => params[:user_id], :date => params[:date])
  end

  def counterpost
    @user_id = params[:user_id]
    time_entry = TimeEntry.find(params[:id])
    if time_entry.counterpost
      @counterpost = time_entry
      @time_entry = TimeEntry.find(:user => time_entry.user, :activity => time_entry.activity, :date => time_entry.date, :counterpost => false)
    else
      @time_entry = time_entry
      @counterpost = @current_user.time_entries.new(:date => @time_entry.date, :activity => @time_entry.activity, :counterpost => true)
    end
    #display the number of hours worked, not the correction
    @counterpost.hours = @counterpost.hours + @time_entry.hours
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
    redirect_to user_time_entries_url(:user_id => params[:user_id], :date => params[:date])
  end
  
  def change_user
    if request.post?
      redirect_to user_time_entries_url(:user_id => params[:user_id], :date => params[:date])
    end
  end
  
  private
  
  # If a non admin user attempts to view time entries for a different user,
  # substitute the given user_id with the offending users own id.
  # Watch him squirm as his own sordid time entry details are revealed.
  def check_admin_if_new_user_id
    if !params[:user_id].blank? && params[:user_id].to_i != @current_user.id && !@current_user.admin
      params[:user_id] = @current_user.id.to_s
      flash[:error] = "Mind your own business"
    end
  end
    
  def init_time_entries_and_activities
    @time_entries = @user.time_entries.between(@date, @date.+(6))
    @activities = @time_entries.collect { |te| te.activity }.uniq
  end
  
  # Initializes an array of arrays [[ name, id ]] for use as select options in the view.
  # If the name of an activity in the user_and_default_activities array is present in 
  # the @activities map keyset, that activity will not be available as an option. 
  # The rationale is: An activity can only have one set of time entries per user per week. 
  def find_activity_options
    user_and_default_activities = ( @user.activities + Activity.find_all_by_default_activity(true) ).uniq
    @activity_options = user_and_default_activities.collect { |a| @activities.include?(a) ? nil : [ a.name, a.id ] }.compact
  end
      
end