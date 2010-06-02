class MonthReviewsController < ApplicationController
  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @beginning_of_month = parse_or_create_date
    @month = UserWorkMonth.new(@user, @beginning_of_month)
    @period = Period.new(@user, @beginning_of_month.year, @beginning_of_month.month)
    @activities_summary = create_activity_summary(@user, @period)   
  end
  
  private
  
  def create_activity_summary(user,period)
    billable = []
    unbillable = []

    period.activities.sort.each do |activity| entry = {
       :name => activity.customer_project_name(50),
        :hours => activity.time_entries.for_user(user).between(period.start, period.end).sum(:hours) }
      activity.project.customer.billable ? billable << entry : unbillable << entry
    end
    { :billable => billable, :unbillable => unbillable }
  end

end