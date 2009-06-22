require 'date_extensions'

class TimeEntriesController < ApplicationController
  
  before_filter :check_authentication
  
  Weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] 
  
  def index
  end
  
  def new
    @user = @current_user
    @date = Date.today.beginning_of_week
    @time_entries = []
    7.times { |i|
      date = @date.+(i) 
      @time_entries << @user.time_entries.build(:date => date) 
    }
  end
  
  def create
  end
  
  def edit
  end
  
  def destroy
  end
  
  
end