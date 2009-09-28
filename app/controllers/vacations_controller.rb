class VacationsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin, :except => [:index, :set_vacation]

  def index
    @day = params[:date].blank? ? Date.today.beginning_of_month : Date.parse(params[:date]).at_beginning_of_month
    
    @is_holiday = {}
    @day.at_beginning_of_month.upto @day.at_end_of_month do |d|
      @is_holiday.merge!({d => Holiday.expected_on_day(d) == 0})
    end

    @last_in_month = (@day >> 1) -1
    @user = current_user_session.user
    @others = User.all.sort!
    @others.delete(@user)
  end

  def vacation_overview
    @year = params[:year].blank? ? Date.today.year : params[:year].to_i
  end

  def set_vacation
    user = User.find params[:user_id]
    if user == current_user_session.user || current_user_session.user.admin
      month = Date.parse( params[:month])

      activity = Configuration.instance.vacation_activity
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

    redirect_to :action => 'index', :date => month
  end

end
