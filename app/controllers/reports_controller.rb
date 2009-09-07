require 'ruport'

class ReportsController < ApplicationController
  
  include Reporting

  before_filter :check_authentication, :check_admin

  def index
    redirect_to(:action => 'billing')
  end

  # Remove?
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

  # With the selected project this method will either mark entries as billed,
  # or display a pdf invoice depending on submit name.
  #
  def billing_action
    setup_calender

    if params[:project]
      project_keys = params[:project].keys
      @projects = project_keys.map{|key| Project.find(key.to_i)}

      if params[:report]
        @from_day = @day
        @to_day = @day.at_end_of_month
        prawnto :prawn => prawn_params, :filename=>"billing_report.pdf"
        render :billing_report, :layout=>false
      else
        @projects.each do |p|
          TimeEntry.mark_as_billed( TimeEntry.for_project(p).between(@day, @day.at_end_of_month) , true)
        end
        redirect_to params.merge( :action => 'billing', :format => 'html' )
      end

    else
      flash[:error] = "No projects selected"
      redirect_to :action => 'billing', :month => @day.month, :year => @day.year
    end
  end

  def update_billing_content
    if request.xhr?
      setup_calender
      render :partial => 'billing_content', :locals => { :day => @day}
    end
  end

  # Remove?
  def summary
    setup_calender
    parse_search_params

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
    parse_search_params
    create_search_report
    
    respond_to do |format|
      format.html do
        
      end
      format.pdf  do
        @parameters = []
        @parameters << ["Periode","#{@from_day} to #{@to_day}"]
        @parameters << ["Bruker",@user.fullname] if @user
        @parameters << ["Fakturert",params[:billed] == "true" ? "Ja" : "Nei" ] if params[:billed] && params[:billed] != ""
        @parameters << ["Kunde",@customer.name] if @customer
        @parameters << ["Prosjekt",@project.name]  if @project
        @parameters << ["Kategori",@tag_type.name] if @tag_type
        @parameters << ["Tag",@tag.name] if @tag

        prawnto :prawn => prawn_params, :filename=>"billing_report.pdf"
        render :search, :layout=>false
      end
    end

  end

  def update_search_advanced_form
    if request.xhr?
      setup_calender
      parse_search_params
      render :partial => 'search_advanced_form', :locals => { :params => params, :tag_type => @tag_type, :customer => @customer, :years => @years, :months => @months }
    end
  end

  def update_search_content
    if request.xhr?
      setup_calender
      parse_search_params
      create_search_report
      render :partial => 'search_content', :locals => { :table => @billing_report}
    end
  end

  def mark_time_entries
    if params[:method] == 'post'
      setup_calender
      parse_search_params
      create_search_report

      value = (params[:value] && params[:value] == "true")

      if params[:mark_as] == 'billed'
        TimeEntry.mark_as_billed(@time_entries, value)
      elsif params[:mark_as] == 'locked'
        TimeEntry.mark_as_locked(@time_entries, value)
      end
    end
    redirect_to( params.merge( {:action => 'search'}) )
  end

  private

  def parse_search_params
    params[:month] ||= @day.month
    
    if params[:from_day]
      @from_day = set_date(params[:from_year].to_i, params[:from_month].to_i, params[:from_day].to_i)
      @to_day = set_date(params[:to_year].to_i, params[:to_month].to_i, params[:to_day].to_i)
    else
      @from_day = @day
      @to_day = @day.at_end_of_month
    end

    @customer = param_instance(:customer)
    @project = param_instance(:project)    
    @tag_type = param_instance(:tag_type)
    @tag = param_instance(:tag)
    @user = param_instance(:user)

  end

  def create_search_report
    activities = Activity.search(params[:tag_type], params[:tag], params[:customer], params[:project])

    unless  activities.empty?
      @time_entries = TimeEntry.search( @from_day, @to_day, activities, @user, params[:billed] )
    end

    @group_by = params[:group_by].to_sym if params[:group_by] && params[:group_by] != ""
    @group_by ||= :user
  end


end