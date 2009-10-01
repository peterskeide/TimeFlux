class VacationsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_parent_user, :only => [:edit, :update]

  def index
    @year = params[:year].blank? ? Date.today.year : params[:year].to_i
    @users = User.all_except(@current_user).sort.unshift(@current_user)
  end
  
  def edit
    @day = params[:date].blank? ? Date.today.beginning_of_month : Date.parse(params[:date]).at_beginning_of_month    
    @holidays = Holiday.holidays_between(@day, @day.end_of_month)
    @others = User.all_except(@current_user).sort
  end

  def update
    start_of_month = Date.parse(params[:start_of_month])
    end_of_month = start_of_month.end_of_month
    @current_user.update_vacation!(start_of_month, end_of_month, params[:dates])
    flash[:notice] = "Vacation updated"
    redirect_to vacations_url(:year => start_of_month.year)
  end
  
end