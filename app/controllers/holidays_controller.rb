class HolidaysController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin, :except => [:index, :vacation, :set_vacation]

  def index
    @holidays = Holiday.all.sort
  end

  def new
    @holiday = Holiday.new
    render :action => "edit"
  end

  def edit
    @holiday = Holiday.find(params[:id])
  end

  def create
    @holiday = Holiday.new(params[:holiday])
    if @holiday.save
      flash[:notice] = 'Holiday was successfully created.'
      redirect_to :controller => 'holidays'
    else
      render :action => "edit"
    end
  end

  #HACK For repeated hloidays we the year with javascript to 1992 (for non-database specific extraction)
  def update
    @holiday = Holiday.find(params[:id])
    @holiday.update_attributes(params[:holiday])
    
    if @holiday.save
      redirect_to :controller => 'holidays'
    else
      render :action => "edit"
    end
  end

  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy
    redirect_to :controller => 'holidays'
  end



  def vacation
    setup_calender
    if params[:date]
      @day = Date.parse(params[:date])
    end
    @last_in_month = (@day >> 1) -1
    @user = current_user_session.user
    @others = User.all
    @others.delete(@user)
  end

  def set_vacation
    user = User.find params[:user_id]
    if user == current_user_session.user || current_user_session.user.admin
      month = Date.parse( params[:month])
      
      #HARDCODED to activity named "Vacation"
      activity = Activity.find_by_name("Vacation")
      month.upto((month >> 1) - 1) do |day|
        if params[:date].try("[]".to_sym, day.to_s)
          current = TimeEntry.for_user(user).for_activity(activity).on_day(day)
          if current.empty?
            TimeEntry.create(:activity => activity, :date => day, :user_id => user.id, :hours => 7.5)
          end
        else
          current = TimeEntry.for_user(user).for_activity(activity).on_day(day)
          unless current.empty?
            current.first.destroy
          end
        end
      end
    else
      flash[:error] = "No permission to perform this task"
    end

    redirect_to :action => :vacation, :date => month
  end

end
