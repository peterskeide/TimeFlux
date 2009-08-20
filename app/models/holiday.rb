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
  
  def self.expected_between(from_date, to_date)
    #HACK Repeating holidays have year set to 1992 (avoids database specific SQL)
    repeating_from = Date.civil(1992,from_date.month,from_date.mday)
    repeating_to   = Date.civil(1992,to_date.month,to_date.mday)

    repeating = Holiday.find(:all, :conditions => { :date => (repeating_from .. repeating_to) })
    one_time =  Holiday.find(:all, :conditions => { :date => (from_date .. to_date) })

    if (repeating.size == 0 && one_time.size == 0 )
      return 37.5
    else
      sum = 0
      (from_date .. to_date).each{|day| sum += expected_on_day(day) }
      return sum
    end
  end

end
