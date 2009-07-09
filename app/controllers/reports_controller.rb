
require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    @reports = self.__send__(:action_methods).delete("index").sort
  end

  def activity
     if params[:active] then
      activities = Activity.find(:all, :conditions => { :active => params[:active] == 'true'} )
    else
      activities = Activity.find(:all)
    end
    
    activity_data = activities.sort.collect { |a|
      [a.name, a.tags.join(', '), a.active]
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
        
    user_data = users.sort.collect { |u|
      [u.fullname, u.login, u.email, u.operative_status]
    }
    @table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name', 'Login', 'E-mail', 'Status'] )
    respond_with_formatter @table, TestController, "User report"
  end


  #Supports GET and POST
  def unbilled
    setup_calender

    report_data = []
    TimeEntry.unbilled.between(@day,(@day >> 1) -1).sort.each do |t|
      if params[:method] == 'post' then t.billed = true; t.save; end
      report_data << [t.activity.name, t.date, t.hours, t.user.fullname, t.billed, t.notes] if t.hours > 0
    end

    table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity name', 'Date', 'Hours', 'Consultant', 'Billed','Notes'])
    grouping = Grouping(table,:by => "Activity name")

    result = Ruport::Data::Grouping.new
    grouping.each do |name,group|
      g2 = Grouping(group,:by => "Consultant")
      g2.each do |n2,g3|
        result << Ruport::Data::Group.new( :name => "#{name} - #{n2}",
                    :data => g3.data,
                    :column_names => g3.column_names )
      end
    end

    respond_with_formatter result, ReportRendererUnbilled, "Unbilled_#{@day.year}-#{@day.month}"
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

        activity.time_entries.between(@day,(@day >> 1) -1).sort.each do |t|
          if params[:method] == 'post' then t.billed = true; t.save; end
          report_data << [activity.name, t.date, t.hours, t.user.fullname, t.billed, t.notes] if t.hours > 0
        end
      end
      table = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Activity name', 'Date', 'Hours', 'Consultant', 'Billed','Notes'])

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