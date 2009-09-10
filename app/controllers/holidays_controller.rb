class HolidaysController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin, :except => [:index, :holiday, :vacation, :set_vacation]

  def index
    redirect_to(:action => 'vacation')
  end
  
  def holiday
    @holidays = Holiday.all.sort
  end

  def new
    @holiday = Holiday.new
  end

  def edit
    @holiday = Holiday.find(params[:id])
  end

  def create
    @holiday = Holiday.new(params[:holiday])
    if @holiday.save
      flash[:notice] = 'Holiday was successfully created.'
      redirect_to :action => 'holiday'
    else
      render :action => "edit"
    end
  end

  #HACK For repeated holidays we the year with javascript to 1992 (for non-database specific extraction)
  def update
    @holiday = Holiday.find(params[:id])
    @holiday.update_attributes(params[:holiday])
    
    if @holiday.save
      redirect_to :action => 'holiday'
    else
      render :action => "edit"
    end
  end

  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy
    redirect_to :action => 'holiday'
  end

  def vacation
    @day = params[:date].blank? ? Date.today.beginning_of_month : Date.parse(params[:date])

    @last_in_month = (@day >> 1) -1
    @user = current_user_session.user
    @others = User.all.sort!
    @others.delete(@user)
  end

  def set_vacation
    user = User.find params[:user_id]
    if user == current_user_session.user || current_user_session.user.admin
      month = Date.parse( params[:month])
      
      #HARDCODED to activity named "Vacation"
      activity = Activity.vacation
      hour_type = HourType.find_by_default_hour_type(true)
      month.upto((month >> 1) - 1) do |day|
        if params[:date].try("[]".to_sym, day.to_s)
          current = TimeEntry.for_user(user).for_activity(activity).on_day(day)
          if current.empty?
            t = TimeEntry.create(:activity => activity, :hour_type => hour_type, :date => day, :user_id => user.id, :hours => 7.5)
          end
        else
          current = TimeEntry.for_user(user).for_activity(activity).on_day(day)
          unless current.empty?
            current.first.destroy
          end
        end
      end
      flash[:notice] = "Vacation updated for #{user.name}"
    else
      flash[:error] = "No permission to perform this task"
    end

    redirect_to :action => 'vacation', :date => month
  end

end
