class MonthReviewsController < ApplicationController
  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @beginning_of_month = parse_or_create_date
    @month = UserWorkMonth.new(@user, @beginning_of_month)
    @period = Period.new(@user, @beginning_of_month.year, @beginning_of_month.month)
  end
  
end