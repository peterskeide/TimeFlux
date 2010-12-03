
class ReportsController < ApplicationController
  
  include Reporting

  before_filter :check_authentication, :check_admin

  def index
  end

  def user
    setup_calender
    @users = User.active.paginate :page => params[:page] || 1, :per_page => 30, :order => 'lastname'

    first_day = @day.at_beginning_of_month
    last_day = @day.at_end_of_month
    first_week = [first_day,first_day.end_of_week]
    last_week = [last_day.beginning_of_week,last_day]

    date_iterator = first_day.end_of_week + 1 #monday in the second week of the month
    middle_weeks = []
    until date_iterator == last_day.beginning_of_week
      middle_weeks << [date_iterator, date_iterator + 6]
      date_iterator += 7
    end

    @weeks = [first_week] + middle_weeks + [last_week]

    @expected = @weeks.collect do |from, to|
      Holiday.expected_hours_between( from,to )
    end

    @totals = @weeks.collect do |day, to|
      TimeEntry.between(day, to).sum(:hours)
    end
  end

  def billing
    setup_calender
    params[:letter] ||= "A"

    billable_customers = Customer.billable(true).to_a
    @letters, @other = extract_customers_by_letter( billable_customers, @day )

    @customers = case params[:letter]
    when '*' then 
      Customer.billable(true).paginate :page => params[:page] || 1, :per_page => 100, :order => 'name'
    when '#' then
      @other.paginate :page => params[:page] || 1, :per_page => 25, :order => 'name'
    else
      Customer.billable(true).on_letter(params[:letter]).paginate :page => params[:page] || 1, :per_page => 25, :order => 'name'
    end

  end



  # With the selected project this method will either mark entries as billed,
  # or display a pdf invoice depending on submit name.
  #
  def billing_action
    setup_calender

    if params[:project]
      project_keys = params[:project].keys
      @projects = project_keys.map{|key| Project.find(key.to_i)}.sort

      if params[:report]
        @from_day = @day
        @to_day = @day.at_end_of_month
        initialize_pdf_download("#{t'invoice.filename'}.pdf")
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

  def details
    @user = User.find(params[:user])
    @project = Project.find(params[:project])
    @day = Date.parse(params[:day])
    @time_entries = TimeEntry.for_user(@user).for_project(@project).between(@day, @day.at_end_of_month).sort
  end

  def customer
    setup_calender
    parse_search_params
    @hide_inactive = params[:hide_inactive]
    billable = project_hours_for_customers(Customer.billable(true))
    internal = project_hours_for_customers(Customer.billable(false))
    @billable_project_hours = @hide_inactive ? billable.find_all{|customer,project,hours| hours > 0 } : billable
    @internal_project_hours = @hide_inactive ? internal.find_all{|customer,project,hours| hours > 0 } : internal
  end

  def project
    setup_calender
    parse_search_params
    @user_activity_hours = []
    @project.activities.each do |activity|
      User.all.each do |user|
        hours = TimeEntry.between(@from_day, @to_day).for_user(user).for_activity(activity).sum(:hours)
        @user_activity_hours << [user,activity, hours] if hours > 0
      end
    end
  end

  def update_project_content
    if request.xhr?
      project()
      render :partial => 'project_content', :locals => { :user_activity_hours => @user_activity_hours}
    end
  end

  def search
    setup_calender
    parse_search_params
    create_search_report
    
    respond_to do |format|
      format.html { }
      format.csv {}
      format.pdf  do
        @parameters = []
        @parameters << [t('common.period'),"#{@from_day} to #{@to_day}"]
        @parameters << [t('common.person'),@user.fullname] if @user
        @parameters << [t('common.billable'),@billed ? "Ja" : "Nei"] if @billed
        @parameters << [t('common.customer'),@customer.name] if @customer
        @parameters << [t('common.project'),@project.name]  if @project
        @parameters << [t('common.category'),@tag_type.name] if @tag_type
        @parameters << [t('common.tag'),@tag.name] if @tag

        initialize_pdf_download("search_report.pdf")
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
      search()
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
    redirect_to( {:action => 'search'}.merge(params) )
  end

  def audit
    setup_calender

    if params[:from_day] && params[:from_day] != ""
      @from_day = set_date(params[:from_year].to_i, params[:from_month].to_i, params[:from_day].to_i)
      @to_day = set_date(params[:to_year].to_i, params[:to_month].to_i, params[:to_day].to_i)
    elsif params[:from_date] && params[:from_date] != ""
      @from_day = params[:from_date]
      @to_day = params[:to_date]
    else
      @from_day = @day
      @to_day = @day.at_end_of_month
    end

    @time_entries = TimeEntry.between(@from_day,@to_day).all(:select => "time_entries.user_id, min(time_entries.activity_id) AS activity_id, SUM(time_entries.hours) AS sum_hours",
  :joins => :activity, :group => "time_entries.user_id   ,activities.project_id")
    @time_entries = @time_entries.sort_by { |a| [ a.user.lastname, a.activity.customer.name, a.activity.project.name  ] }

    respond_to do |format|
      format.html {}
      format.csv {}
      format.pdf  do
        initialize_pdf_download("audit_report.pdf")
        render :revisor, :layout=>false
      end
    end
  end

  private

  def parse_search_params
    params[:month] ||= @day.month

    if params[:from_day] && params[:from_day] != ""
      @from_day = set_date(params[:from_year].to_i, params[:from_month].to_i, params[:from_day].to_i)
      @to_day = set_date(params[:to_year].to_i, params[:to_month].to_i, params[:to_day].to_i)
    else
      @from_day = @day
      @to_day = @day.at_end_of_month
    end

    unless params[:customer] == "*"
      @customer = param_instance(:customer)
    end
    @project = param_instance(:project)
    @user = param_instance(:user)
    @tag_type = param_instance(:tag_type)
    @tag = param_instance(:tag)
    @status = params[:status].to_i if params[:status] && params[:status] != ""
  end

  def create_search_report
    if params[:customer] && params[:customer] != ""
      @time_entries = TimeEntry.search(@from_day,@to_day,@customer,@project,@tag,@tag_type,@user,@status).sort
    end
    @group_by = params[:group_by].to_sym if params[:group_by] && params[:group_by] != ""
    @group_by ||= :user
  end
  
end