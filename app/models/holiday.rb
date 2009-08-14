class Holiday < ActiveRecord::Base

  validates_uniqueness_of :date
  validates_numericality_of :working_hours, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 24.0
  validates_presence_of :note

  def <=>(other)
    date.yday <=> other.date.yday
  end

  def show_date
    if repeat
      "#{date.mday} #{Holiday.months[date.month - 1][0]}"
    else
      "#{date.mday} #{Holiday.months[date.month - 1][0]}, #{date.year}"
    end
  end

  def self.months
    [['January',1],['Febrary',2],['March',3],['April',4],['May',5],['June',6],
     ['July',7],['August',8],['September',9],['October',10],['November',11],['December',12]]
  end

  def self.years
    #[['Any',1]] +
      ( 2009..Date.today.year+3 ).map{|i| i}
  end

  def self.expected_hours_for(date)
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

  # Note: a year specific holiday trumphs a repeating holiday
  def self.on_day(date)
    ret = Holiday.find(:all, :conditions => { :date => date})
    ret ||= Holiday.find(:all, :conditions => { :date => (date.year=1992)})
    ret ||= []
    return ret
  end

  #TODO make efficient
  def self.expected_hours_between(from_date, to_date)
    sum = 0
    (from_date .. to_date).each{ |date| sum += expected_hours_for(date) }
    return sum
  end
end
