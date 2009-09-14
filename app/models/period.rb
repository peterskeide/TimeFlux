class Period
      
  attr_reader :expected_hours, :total_hours, :expected_days, :start, :end, :time_entries
  
  def initialize(user, year, month)
    @start = Date.new(year, month, 1)
    @end = @start.end_of_month
    @user = user
    @time_entries = @user.time_entries.between(@start, @end)
    @total_hours = @time_entries.collect { |te| te.hours }.sum
    #@total_days = @user.time_entries.between(@start, @end).distinct_dates.count
    @expected_hours = find_expected_hours
    @expected_days = find_expected_days
    @locked = is_period_locked?
  end
  
  def ready_for_approval?
    @total_hours >= @expected_hours
  end
  
  def locked?
    @locked
  end

  def month_name
    Date::MONTHNAMES[@start.month]
  end

  # Why doesn´t distinct_days work?
  def total_days
    list = {}
    TimeEntry.for_user(@user).between(@start, @end).each { |i| list.merge!({i.date => true}) }
    list.size
  end

  def activities
    @user.time_entries.between(@start, @end).distinct_activities.map { |e| e.activity }
  end
  
  private
  
  def find_expected_hours
    period = expected_between_hash(@start, @end)
    sum = 0
    period.each_value { |value| sum = sum + value }
    sum
  end
  
  def find_expected_days
    period = expected_between_hash(@start, @end)
    days = 0
    period.each_value { |value| days += 1 if value > 0}
    days
  end
  
  def is_period_locked?
    locked_status = @time_entries.map { |te| te.locked }.uniq
  	locked_status.size == 1 and not locked_status.include? false
  end

  # Cannot span multiple years with current hack...
  def expected_between_hash(from_date, to_date)
    #HACK Repeating holidays have year set to 1992 (avoids database specific SQL)
    repeating_from = Date.civil(1992,from_date.month,from_date.mday)
    repeating_to   = Date.civil(1992,to_date.month,to_date.mday)

    repeating = Holiday.find(:all, :conditions => { :date => (repeating_from .. repeating_to) })
    one_time =  Holiday.find(:all, :conditions => { :date => (from_date .. to_date) })

    period = {}
    (from_date .. to_date).each{ |day| period.merge!( day => day.cwday >= 6 ? 0 : 7.5 ) }
    repeating.each{|holiday| period.merge!( Holiday.date_for_repeating(holiday, from_date, to_date)  => holiday.working_hours ) }
    one_time.each{|holiday| period.merge!( holiday.date => holiday.working_hours ) }

    period
  end

  def date_for_repeating(holiday, from_date, to_date)
    in_from_date = Date.civil(from_date.year, holiday.date.month, holiday.date.mday)
    in_to_date = Date.civil(to_date.year, holiday.date.month, holiday.date.mday)

    if (from_date .. to_date).include? in_from_date
      return in_from_date
    elsif (from_date .. to_date).include? in_to_date
      return in_to_date
    else
      raise "Could not find date in either year "
    end
  end
    
end