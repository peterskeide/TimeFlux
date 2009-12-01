class MonthListingsController < ApplicationController
  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @beginning_of_month = parse_or_create_date   
    @end_of_month = @beginning_of_month.end_of_month
    @time_entries = @user.time_entries.between(@beginning_of_month, @end_of_month).group_by(&:activity)
    respond_to do |format|
      format.html {}
      format.pdf { render :template => "month_listings/show.pdf.prawn" }
    end
  end

end