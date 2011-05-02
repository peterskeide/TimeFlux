class Period
      
  attr_reader :expected_hours, :total_hours, :expected_days, :total_days, :start, :end, :has_statistics, :balance, :balance_workdays, :billing_degree, :time_entries
  attr_reader :expected_hours_per_day_in_period

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

    reported_upto_day = find_reported_upto_day
    if reported_upto_day
      @balance_workdays = find_expected_days(@start, reported_upto_day) if reported_upto_day != @end
      @balance = find_balance(@start,reported_upto_day)
      @billing_degree = find_billing_degree(@start,reported_upto_day)
      @has_statistics = true
    else
      @has_statistics = false
    end

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
    @user.time_entries.between(@start, @end).distinct_activities.map { |e| e.activity }
  end

  private

  def find_reported_upto_day
    today = Date.today
    if today.month == @start.month && today.year == @start.year
      @user.time_entries.on_day(today).empty? ? today - 1: today
    elsif today > @end
      @end
    else
      nil
    end
  end

  def find_billing_degree(from=@start, to=@end)
    sum_billable = 0
    Customer.billable(true).each do |customer|
      customer.projects.each do |project|
        sum_billable += @user.time_entries.between(from, to).for_project(project).sum(:hours)
      end
    end

    if sum_billable > 0 then
      sum_billable / find_expected_hours(from, to)
    else
      0
    end
  end
  
  def find_balance(from=@start, to=@end)
    today = Time.zone.now.to_date
    if today > @end
      @total_hours - @expected_hours
    elsif (from..@end).include?(today)
      expected = find_expected_hours(from, to)
      actual = @user.time_entries.between(from, to).sum(:hours)
      actual - expected
    else
      0
    end
  end

  def find_expected_hours(from=@start, to=@end)
    sum = 0
    @expected_hours_per_day_in_period.each { |date, value| sum = sum + value if (from..to).include?(date) }
    sum == 0 ? 1 : sum
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