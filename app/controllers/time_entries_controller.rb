require 'date_extensions'

class TimeEntriesController < ApplicationController
  
  before_filter :check_authentication
  
  Weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] 
  
  def index
  end
  
  def new
    @user = User.new
    @date = Date.today.beginning_of_week
    7.times { |i| @user.time_entries.build(:date => @date.+(i)) }
  end
  
  def create
  end
  
  def edit
  end
  
  def destroy
  end
  
  
end