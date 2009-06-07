require File.dirname(__FILE__) + "/../classes/date_extensions"

class TimeEntriesController < ApplicationController

  def index
    @activities = Activity.find(:all)
  end
  
  def new
    @week = Date.week_of_date
    create_time_entries
  end
  
  def next_week
    date = Date.parse(params[:date]).+ 7
    create_week_and_render(date)
  end
  
  def previous_week
    date = Date.parse(params[:date]).- 7
    create_week_and_render(date)
  end
  
  def create
    @time_entry = TimeEntry.new(params[:time_entry])
    if @time_entry.save
      flash[:notice] = "Time entry successfully created"
      redirect_to :action => "new"   
    else
      flash[:error] = @category.errors.full_messages.to_s
      redirect_to :action => "new"
    end
  end
  
  private
  
  def create_week_and_render(date)
    @week = Date.week_of_date(date)
    create_time_entries
    render :action => "new"
  end
  
  def create_time_entries
    @week_number = @week[:thursday].cweek
    @monday = TimeEntry.new(:date => @week[:monday])
    @tuesday = TimeEntry.new(:date => @week[:tuesday])
    @wednesday = TimeEntry.new(:date => @week[:wednesday])
    @thursday = TimeEntry.new(:date => @week[:thursday])
    @friday = TimeEntry.new(:date => @week[:friday])
    @saturday = TimeEntry.new(:date => @week[:saturday])
    @sunday = TimeEntry.new(:date => @week[:sunday])
  end

end