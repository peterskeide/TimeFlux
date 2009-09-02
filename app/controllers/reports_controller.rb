
require 'ruport'

class ReportsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    redirect_to(:action => 'billing')
    #  @reports = self.__send__(:action_methods).delete("index").sort
  end

  def user
    setup_calender
    if params[:status] then
      @users = User.find(:all, :conditions => ["operative_status=? ", params[:status]] ).sort
    else
      @users = User.find(:all).sort
    end

    start = Date.today.beginning_of_week
    @weeks = []
    1..8.times { |i| @weeks << start - (i * 7) }

    user_data = @users.collect do |user|
      [user.fullname] + @weeks.collect do |day|
        TimeEntry.for_user(user).between(day, (day + 6)).sum(:hours)
      end
    end

    @expected = @weeks.collect do |day|
      Holiday.expected_hours_between( day, (day + 5) )
    end
    user_data << ["Expected"] + @expected

    @totals = @weeks.collect do |day|
      TimeEntry.between(day, (day + 6)).sum(:hours)
    end
    user_data << ["Total"] + @totals

    table = Ruport::Data::Table.new( :data => user_data,
      :column_names => ['Full name'] + @weeks.collect { |d| "Week #{d.cweek}" } )
    respond_with_formatter table, TestController, "User report"
  end

  def billing
    setup_calender
  end

  def billing_action
    setup_calender
    @from_day = @day
    @to_day = (@day >> 1) -1

    if params[:project]
      project_keys = params[:project].keys
      @projects = project_keys.map{|key| Project.find(key.to_i)}
      @projects.reject { |p| TimeEntry.for_project(p).between(@from_day, @to_day).sum(:hours) == 0 }
    else
      @projects = []
    end

    if params[:report]
      prawnto :prawn => {
      :page_size => 'A4',
      :left_margin => 50,
      :right_margin => 50,
      :top_margin => 24,
      :bottom_margin => 24},
      :filename=>"billing_report.pdf"
      render :billing_report, :layout=>false
    else
      @projects.each do |p|
        TimeEntry.mark_as_billed( TimeEntry.for_project(p).between(@from_day, @to_day) , true)
      end
      redirect_to params.merge( :action => 'billing', :format => 'html' )
    end

  end

  def update_billing_content
    if request.xhr?
      setup_calender
      render :partial => 'billing_content', :locals => { :day => @day}
    end
  end

  def calender
    @user = User.find(params[:user])
    @day = Date.parse(params[:day])
    @activity_summary = create_activity_summary(@day, @user)
  end

  def details
    @user = User.find(params[:user])
    @project = Project.find(params[:project])
    @day = Date.parse(params[:day])
  end


  def summary
    setup_calender
    setup_hours_form

    time_entries = TimeEntry.search( @from_day, @to_day, @activities )

    data_set = time_entries.group_by(&:activity).collect do |activity, time_entries|
      [activity.name, time_entries.sum(&:hours)]
    end

    table = Ruport::Data::Table.new( :data => data_set,
      :column_names => ['Activity', 'hours'])

    respond_with_formatter table, TestController, @activities
  end

  def search
    setup_calender
    setup_hours_form
    create_search_report

    @parameters = []
    @parameters << ["Periode","#{@from_day} to #{@to_day}"]
    @parameters << ["Bruker",@user.fullname] if @user
    @parameters << ["Fakturert",params[:billed] == "true" ? "Ja" : "Nei" ] if params[:billed] && params[:billed] != ""
    @parameters << ["Kunde",@customer.name] if @customer
    @parameters << ["Prosjekt",@project.name]  if @project
    @parameters << ["Kategori",@tag_type.name] if @tag_type
    @parameters << ["Tag",@tag.name] if @tag

    @table = @billing_report
    @title = "Search report"


    #### This report is also prawned, uncomment to use ruport (txt, csv support).
    #respond_with_formatter( apply_formatting(@billing_report), TestController, "Hour report",
    #  {:page_break => @page_break, :customer => @customer.try("name"), :project => @project, :date_range => @date_range} )
  end

  def mark_time_entries
    if params[:method] == 'post'
      setup_calender
      setup_hours_form
      create_search_report

      value = (params[:value] && params[:value] == "true") ? true : false

      if params[:mark_as] == 'billed'
        TimeEntry.mark_as_billed(@time_entries, value)
      elsif params[:mark_as] == 'locked'
        TimeEntry.mark_as_locked(@time_entries, value)
      end
    end
    redirect_to( params.merge( {:action => 'search'}) )
  end

  def update_search_advanced_form
    if request.xhr?
      setup_calender
      setup_hours_form
      render :partial => 'search_advanced_form', :locals => { :params => params, :tag_type => @tag_type, :customer => @customer, :years => @years, :months => @months }
    end
  end

  def update_search_content
    if request.xhr?
      setup_calender
      setup_hours_form
      create_search_report
      render :partial => 'search_content', :locals => { :table => @billing_report}
    end
  end

  private

  def apply_formatting(table)
    if params[:sort_by]
      table.sort_rows_by!( params[:sort_by].split(' - ') )
    end

    table.remove_column('Notes') if params[:remove_comments]

    if params[:grouping] && params[:grouping] != ""
      return Grouping(table,:by => params[:grouping])
    end
    return table
  end

  def setup_hours_form
    params[:month] ||= @day.month
    
    if params[:from_day]
      @from_day = set_date(params[:from_year].to_i, params[:from_month].to_i, params[:from_day].to_i)
      @to_day = set_date(params[:to_year].to_i, params[:to_month].to_i, params[:to_day].to_i)
    else
      @from_day = @day
      @to_day = (@day >> 1) -1
    end

    @customer = param_instance(:customer)
    @project = param_instance(:project)    
    @tag_type = param_instance(:tag_type)
    @tag = param_instance(:tag)
    @user = param_instance(:user)

  end
  
  def set_date(year, month, day)
    max_day = Date.civil(year,month,1).at_end_of_month.mday
    Date.new(year,month, day > max_day ? max_day : day)
  end

  def create_search_report
    activities = Activity.search(params[:tag_type], params[:tag], params[:customer], params[:project])

    report_data = []
    unless  activities.empty?

      @time_entries = TimeEntry.search( @from_day, @to_day, activities, @user, params[:billed] )
      @time_entries.each do |t|
        report_data << [ t.date, t.activity.name, t.hours, t.user.fullname, t.notes ] if t.hours > 0
      end
    end

    @billing_report = Ruport::Data::Table.new( :data => report_data,
      :column_names => ['Date', 'Activity', 'Hours', 'Consultant', 'Notes'])

    @date_range = "Between #{@from_day} and #{@to_day}"
    @page_break = params[:page_break] ? true : false
    @group_by = params[:group_by].to_sym if params[:group_by] && params[:group_by] != ""
    @group_by ||= :user
  end

  def param_instance(symbol)
    Kernel.const_get(symbol.to_s.camelcase).find(params[symbol])  if params[symbol] && params[symbol] != ""
  end
end