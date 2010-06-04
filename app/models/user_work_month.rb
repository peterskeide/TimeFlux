class UserWorkMonth  
  attr_reader :registered_days, :registered_hours, :expected_days, :expected_hours, :activity_summary, :billing_degree, :balance   
 
  def initialize(user, month_start)
    @user = user
    @month_start = month_start
    @month_end = @month_start.end_of_month
    @first_day_of_first_week_of_month = @month_start.beginning_of_week
    @last_day_of_last_week_of_month = @month_end.end_of_week
    @time_entries = user.time_entries.between(@first_day_of_first_week_of_month, @last_day_of_last_week_of_month).all(:order => "date ASC")
    initialize_workdays
    initialize_weeks
    initialize_month_totals
    initialize_activity_summary
    @billing_degree = calculate_billing_degree
    @balance = calculate_balance
  end
  
  def name
    Date::MONTHNAMES[@month_start.month]
  end
  
  def has_statistics?
    @balance != nil && @billing_degree != nil
  end
  
  def each_week(&block)
    @weeks.each { |week| block.call week } 
  end
      
  def initialize_workdays
    @workdays = []
    (@first_day_of_first_week_of_month..@last_day_of_last_week_of_month).to_a.each do |day|
      time_entries_for_day = @time_entries.select { |te| day == te.date }
      in_reported_month = (day >= @month_start && day <= @month_end)
      @workdays << UserWorkDay.new(day, time_entries_for_day, in_reported_month)
    end
  end
  
  def initialize_weeks
    @weeks = []
    weeks_in_month = (@month_start.cweek..@month_end.cweek).to_a
    weeks_in_month.each do |week_nr|
      workdays_in_week = @workdays.select { |wd| week_nr == wd.date.cweek }
      @weeks << UserWorkWeek.new(week_nr, workdays_in_week)
    end
  end
  
  # Totals for the month *excluding* any weekdays in
  # the first and last week of the month that belong to
  # the previous and next months.
  def initialize_month_totals
    workdays_in_month = @workdays.select { |wd| wd.in_reported_month? }
    @registered_hours = workdays_in_month.map { |wd| wd.total_hours }.sum
    @expected_hours = workdays_in_month.map { |wd| wd.date.work_hours }.sum
    @registered_days = workdays_in_month.select { |wd| wd.hours_reported? }.length
    @expected_days = workdays_in_month.select { |wd| wd.date.workday? }.length
  end
  
  def initialize_activity_summary
    time_entries_in_month = @time_entries.select { |te| te.date >= @month_start && te.date <= @month_end }
    @activity_summary = ActivitySummary.new(time_entries_in_month)
  end
  
  def calculate_billing_degree
    registered_billable_hours = @time_entries.select { |te| te.billable? }.map { |te| te.hours }.sum
    if registered_billable_hours > 0
      expected_hours = WorkTimeCalculations.find_expected_workhours_between(@month_start, @month_end)
      ((registered_billable_hours / expected_hours) * 100).round
    else
       0
    end
  end
  
  def calculate_balance
    if today > @month_end
      @registered_hours - @expected_hours
    elsif current_month?
      report_upto_date = find_report_upto_date
      if report_upto_date
        expected = WorkTimeCalculations.find_expected_workhours_between(@month_start, report_upto_date)
        actual = @time_entries.select { |te| te.date >= @month_start && te.date <= report_upto_date }.map { |te| te.hours }.sum
        actual - expected
      else
         0
      end
    else
      0
    end
  end
  
  def current_month?
    @current_month ||= begin
      today.month == @month_start.month
    end
  end
  
  def find_report_upto_date
    if current_month?
      @workdays.select { |wd| today == wd.date }.first.hours_reported? ? today - 1 : today 
    elsif today > @month_end
      @month_end
    else
      nil
    end
  end
  
  def today
    @today ||= Time.zone.now.to_date
  end
        
  private :initialize_workdays, :initialize_weeks, :initialize_month_totals, :today, :current_month?,
          :initialize_activity_summary, :calculate_billing_degree, :calculate_balance, :find_report_upto_date
    
  class UserWorkDay    
    def initialize(date, time_entries, in_reported_month)
      @date = date
      @time_entries = time_entries
      @in_reported_month = in_reported_month   
    end

    attr_reader :date

    def today?
      @date == Time.zone.now.to_date
    end

    def in_reported_month?
      @in_reported_month
    end

    def holiday?
      @date.holiday?
    end
    
    def hours_reported?
      self.total_hours > 0
    end

    def total_hours
      @total_hours ||= @time_entries.map { |te| te.hours }.sum
    end   
  end
  
  class UserWorkWeek
    def initialize(week_nr, workdays)
      @workdays = workdays
      @total_hours = workdays.map { |workday| workday.total_hours }.sum
      @number = week_nr
    end

    attr_reader :number, :total_hours

    def start_date
      @workdays.first.date
    end

    def each_day(&block)
      @workdays.each { |workday| block.call workday }
    end  
  end
  
  class ActivitySummary  
    attr_reader :billable, :unbillable
    
    def initialize(time_entries_in_month)
      @time_entries = time_entries_in_month
      @activities = @time_entries.map { |te| te.activity }.uniq.sort
      @billable = []
      @unbillable = []
      initialize_billable_and_unbillable_activity_summaries
    end
    
    private
    
    def initialize_billable_and_unbillable_activity_summaries
      @activities.sort.each do |activity| 
        entry = {
          :name => activity.customer_project_name(50),
          :hours => @time_entries.select { |te| activity == te.activity }.map { |te| te.hours }.sum
          }
        activity.billable? ? @billable << entry : @unbillable << entry
      end
    end       
  end
end