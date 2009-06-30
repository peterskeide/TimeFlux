Mime::Type.register 'application/pdf', :pdf
#Mime::Type.register 'text/plain', :csv

require 'report_renderer'
require 'test_controller'

require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication

  def index
    @reports = self.__send__(:action_methods).delete("index").sort
  end

  def activity
     if params[:active] then
      activities = Activity.find(:all, :conditions => { :active => params[:active] == 'true'} )
    else
      activities = Activity.find(:all)
    end
    
    activity_data = activities.collect { |a|
      [a.name, a.tags.to_s, a.active]
    }
    @table = Ruport::Data::Table.new( :data => activity_data,
      :column_names => ['Activity name', 'Tags', 'Active'] )
    respond_with_formatter@table, TestController, "Activity report"
  end

  def user
    if params[:status] then
      users = User.find(:all, :conditions => ["operative_status=? ", params[:status]] )
    else
      users = User.find(:all)
    end
        
    user_data = users.collect { |u|
      [u.fullname, u.login, u.email, u.operative_status]
    }
    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name', 'Login', 'E-mail', 'Status'] )
    respond_with_formatter @table, TestController, "User report"
  end

  #Supports GET and POST
  def billing
    setup_calender

    @tag_types = TagType.all
    @tag_type = TagType.find(params[:tag_type]) if params[:tag_type]
    @tag_type ||= TagType.first
    @tags = @tag_type.tags if @tag_type
    @tag = Tag.find(params[:tag]) if params[:tag]

    if @tag
      report_data = []
      @tag.activities.each do |activity|

        activity.time_entries.between(@day,(@day >> 1) -1).each do |t|
          if params[:method] == 'post' then t.billed = true; t.save end
          report_data << [activity.name, t.hours, t.user.fullname, t.billed, t.notes] if t.hours > 0 
        end
      end
      table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity name', 'Hours', 'Consultant', 'Billed','Notes'])

      @table = Grouping(table,:by => "Activity name")
      title = "Hour report for #{@tag.name}"
    end
    respond_with_formatter @table, TestController, title
  end


  def hours
    setup_calender
     
    @selected_user = User.find(params[:user]) if params[:user]
    @selected_user ||= current_user_session.user

    # Content of selects
    @users = User.find(:all)

    time_data = [] 
    @selected_user.time_entries.between(@day,(@day >> 1) -1).each do |t|
      time_data << [t.activity.name, t.hours, t.date, t.notes] if t.hours > 0
    end
    table = Ruport::Data::Table.new( :data => time_data,
      :column_names => ['Activity name', 'Date', 'Hours', 'Notes'])

    @table = Grouping(table,:by => "Activity name")
    respond_with_formatter @table, TestController, "Hour report for user: #{@selected_user.fullname}"
  end

private





end