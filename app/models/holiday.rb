class Holiday < ActiveRecord::Base

  validates_uniqueness_of :date
  validates_presence_of :note
  validates_numericality_of :working_hours, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 24.0

  def <=>(other)
    date.yday <=> other.date.yday
  end

  def show_date
    if repeat
      "#{date.mday} #{Date::MONTHNAMES[date.month]}"
    else
      "#{date.mday} #{Date::MONTHNAMES[date.month]}, #{date.year}"
    end
  end

  # Note: a year specific holiday trumphs a repeating holiday
  def self.on_day(date)
    holiday = Holiday.find(:all, :conditions => { :date => date})
    if holiday.empty?
      holiday = Holiday.find(:all, :conditions => { :date => Date.civil(1992, date.month, date.mday) })
    end
    return holiday
  end

  def self.expected_on_day(date)
    if date.cwday >= 6
      return 0
    end

    holiday = Holiday.on_day(date)
    if holiday.size > 0
      return holiday[0].working_hours
    else
      return 7.5
    end
  end  

  def self.expected_hours_between(from_date, to_date)
    period = Holiday.expected_between_hash(from_date, to_date)
    sum = 0
    period.each_value { |value| sum = sum + value }
    return sum
  end

  def self.expected_days_between(from_date, to_date)
    period = Holiday.expected_between_hash(from_date, to_date)
    days = 0
    period.each_value { |value| days += 1 if value > 0}
    return days
  end
  
  def self.holidays_in_range(from_date, to_date)
    holidays = []
    from_date.upto to_date do |d|
      holidays << d if self.expected_on_day(d) == 0
    end
    holidays     
  end

  private

  # Cannot span multiple years with current hack...
  def self.expected_between_hash(from_date, to_date)
    #HACK Repeating holidays have year set to 1992 (avoids database specific SQL)
    repeating_from = Date.civil(1992,from_date.month,from_date.mday)
    repeating_to   = Date.civil(1992,to_date.month,to_date.mday)

    repeating = Holiday.find(:all, :conditions => { :date => (repeating_from .. repeating_to) })
    one_time =  Holiday.find(:all, :conditions => { :date => (from_date .. to_date) })

    period = {}
    (from_date .. to_date).each{ |day| period.merge!( day => day.cwday >= 6 ? 0 : 7.5 ) }
    repeating.each{|holiday| period.merge!( Holiday.date_for_repeating(holiday, from_date, to_date)  => holiday.working_hours ) }
    one_time.each{|holiday| period.merge!( holiday.date => holiday.working_hours ) }

    return period
  end

  def self.date_for_repeating(holiday, from_date, to_date)
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