class Period
      
  attr_reader :expected_hours, :total_hours, :expected_days, :total_days, :start, :end, :balance, :balance_workdays, :billing_degree, :time_entries
  
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
    @balance_workdays = find_expected_days(@start, reported_upto_day) if reported_upto_day != @end
    @balance = find_balance(@start,reported_upto_day)
    @billing_degree = find_billing_degree(@start,reported_upto_day)

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
    if Date.today > @end
      @end
    elsif (@start...@end).include?(Date.today)
      @user.time_entries.on_day(Date.today).empty? ? Date.today - 1: Date.today
    else
      @start - 1
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
    if Date.today > @end
      @total_hours - @expected_hours
    elsif (from...@end).include?(Date.today)
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
  
#  # Cannot span multiple years with current hack...
#  def expected_between_hash(from_date, to_date)
#    #HACK Repeating holidays have year set to 1992 (avoids database specific SQL)
#    repeating_from = Date.civil(1992,from_date.month,from_date.mday)
#    repeating_to   = Date.civil(1992,to_date.month,to_date.mday)
#
#    repeating = Holiday.find(:all, :conditions => { :date => (repeating_from .. repeating_to) })
#    one_time =  Holiday.find(:all, :conditions => { :date => (from_date .. to_date) })
#
#    # generate plain hash, and overwrite days with repeating and one time holidays
#    vacaition_activity = Configuration.instance.work_hours
#    period = {}
#    (from_date .. to_date).each{ |day| period.merge!( day => day.cwday >= 6 ? 0 : vacaition_activity ) }
#    repeating.each{|holiday| period.merge!( Holiday.date_for_repeating(holiday, from_date, to_date)  => holiday.working_hours ) }
#    one_time.each{|holiday| period.merge!( holiday.date => holiday.working_hours ) }
#
#    period
#  end
#
#  def date_for_repeating(holiday, from_date, to_date)
#    in_from_date = Date.civil(from_date.year, holiday.date.month, holiday.date.mday)
#    in_to_date = Date.civil(to_date.year, holiday.date.month, holiday.date.mday)
#
#    if (from_date .. to_date).include? in_from_date
#      return in_from_date
#    elsif (from_date .. to_date).include? in_to_date
#      return in_to_date
#    else
#      raise "Could not find date in either year "
#    end
#  end
    
end