class VacationsController < ApplicationController

  before_filter :check_authentication
  before_filter :check_parent_user, :only => [:edit, :update]
  before_filter :find_user

  def show
    @year = params[:id].blank? ? Date.today.year : params[:id].to_i    
    @vacation_overview = VacationOverview.for_year_and_user(@year, @user)
  end
  
  def edit
    @day = params[:month].blank? ? Date.today.beginning_of_month : Date.new(params[:id].to_i, params[:month].to_i, 1).at_beginning_of_month
    @holidays = Holiday.holidays_between(@day, @day.end_of_month)
    @others = User.all_active_except(@user).sort
  end

  def update    
    start_of_month = Date.parse(params[:start_of_month])
    end_of_month = start_of_month.end_of_month
    @user.update_vacation!(start_of_month, end_of_month, params[:dates] ? params[:dates].keys : [])
    flash[:notice] = "Vacation updated"
    redirect_to user_vacation_url(@user, :id => start_of_month.year)
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
  
end