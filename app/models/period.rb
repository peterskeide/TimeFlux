class Period
      
  attr_reader :expected_hours, :total_hours, :expected_days, :total_days, :start, :end, :balance, :balance_workdays, :billing_degree
  
  def initialize(user, year, month)
    @start = Date.new(year, month, 1)
    @end = @start.end_of_month
    @user = user
    @time_entries = @user.time_entries.between(@start, @end)
    @total_hours = @time_entries.collect { |te| te.hours }.sum
    @expected_hours_per_day_in_period = Holiday.expected_between_hash(@start, @end)
    @expected_hours = find_expected_hours
    @total_days = @time_entries.distinct_dates.length
    @expected_days = find_expected_days
    @balance, @balance_workdays = find_balance
    @billing_degree = find_billing_degree
    @locked = is_period_locked?
  end
  
  def ready_for_approval?
    (@total_hours >= @expected_hours) && (@total_days >= @expected_days)
  end
  
  def locked?
    @locked
  end

  def month_name
    Date::MONTHNAMES[@start.month]
  end

  def activities
    @time_entries.distinct_activities.map { |e| e.activity }
  end

  private

  def find_billing_degree
    sum_billable = 0
    Customer.billable(true).each do |customer|
      customer.projects.each do |project|
        @time_entries.select { |te| te.project.id == project.id }.each { |te| sum_billable += te.hours }
      end
    end
    sum_billable / @expected_hours
  end
  
  def find_balance
    if Date.today > @end
      [@total_hours - @expected_hours, nil]
    elsif (@start...@end).include?(Date.today)
      balance_upto_day = @time_entries.select { |te| te.date == Date.today }.empty? ? Date.today - 1: Date.today
      balance_workdays = find_expected_days(@start, balance_upto_day)
      expected = find_expected_hours(@start, balance_upto_day)
      actual = 0
      @time_entries.select { |te| te.date <= balance_upto_day }.each { |te| actual += te.hours }
      [actual - expected, balance_workdays]
    else
      [0,nil]
    end
  end

  def find_expected_hours(from=@start, to=@end)
    sum = 0
    @expected_hours_per_day_in_period.each { |date, value| sum = sum + value if (from..to).include?(date) }
    sum
  end
  
  def find_expected_days(from=@start, to=@end)
    days = 0
    @expected_hours_per_day_in_period.each { |date, value| days += 1 if value > 0 && (from..to).include?(date) }
    days
  end
  
  def is_period_locked?
    locked_status = @time_entries.map { |te| te.locked }.uniq
  	locked_status.size == 1 and not locked_status.include? false
  end
    
end