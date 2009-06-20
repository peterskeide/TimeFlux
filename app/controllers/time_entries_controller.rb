require 'date_extensions'

class TimeEntriesController < ApplicationController
  
  Weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] 
  
  def index
  end
  
  def new
    @user = User.find_by_firstname("Bob")
    @date = Date.today.beginning_of_week   
  end
  
  def create
  end
  
  def create_old
    @time_entries = []
    Weekdays.each do |day|
      @time_entries << TimeEntry.new(:date => params["#{day}_date"], :hours => params["#{day}_hours"], :notes => params["#{day}_notes"])
    end
    begin
      TimeEntry.transaction do
        @time_entries.each { |te| te.save } 
      end
      flash[:notice] = "Time entries successfully saved for activity"
      redirect_to week_entries_path 
    rescue
      flash[:notice] = "There were errors"
      @date = Date.today.beginning_of_week
      render :new
    end      
  end
  
  def edit
  end
  
  def destroy
  end
  
  
end