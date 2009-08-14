class HolidaysController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin

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

  def update_holiday_form
    render :text => "hello"
  end

  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy
    redirect_to :controller => 'holidays'
  end
end
