class MonthReview::Calendar 
  attr_reader :days, :weeks
  
  def initialize(time_entries_enumerable, month_start, month_end)
    @time_entries = time_entries_enumerable
    @month_start = month_start
    @month_end = month_end
    initialize_days
    initialize_weeks
  end
  
  def month_name
    Date::MONTHNAMES[@month_start.month]
  end
    
  def initialize_days
    @days = []
    (@month_start.beginning_of_week..@month_end.end_of_week).to_a.each do |day|
      time_entries_for_day = @time_entries.for_date(day)
      in_reported_month = (day >= @month_start && day <= @month_end)
      @days << Day.new(day, time_entries_for_day, in_reported_month)
    end
  end
  
  def initialize_weeks
    @weeks = []
    weeks_in_month = (@month_start.cweek..@month_end.cweek).to_a
    weeks_in_month.each do |week_nr|
      days_in_week = @days.select { |wd| week_nr == wd.date.cweek }
      @weeks << Week.new(week_nr, days_in_week)
    end
  end
       
  private :initialize_days, :initialize_weeks
    
  class Day    
    def initialize(date, time_entries, in_reported_month)
      @date = date
      @time_entries = time_entries
      @in_reported_month = in_reported_month   
    end

    attr_reader :date

    def today?
      @date == today
    end

    def in_reported_month?
      @in_reported_month
    end

    def hours_reported?
      @time_entries.entries.length > 0
    end

    def sum_hours
      @time_entries.sum_hours
    end
    
    private
    
    def today
      @today ||= Time.zone.now.to_date
    end   
  end
  
  class Week
    attr_reader :days
    
    def initialize(week_nr, days)
      @days = days
      @sum_hours = days.map { |day| day.sum_hours }.sum
      @number = week_nr
    end

    attr_reader :number, :sum_hours

    def start_date
      @days.first.date
    end
  end
end