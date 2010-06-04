class MonthReview::Statistics
  attr_reader :registered_hours, :expected_hours, :registered_days, :expected_days
   
  def initialize(time_entry_enumerable, month_start, month_end)
    @month_start, @month_end = month_start, month_end
    @time_entries = time_entry_enumerable
    @registered_hours = @time_entries.sum_hours
    @expected_hours = WorkTimeCalculations.find_expected_workhours_between(@month_start, @month_end)
    @registered_days = @time_entries.sum_days
    @expected_days = WorkTimeCalculations.find_expected_workdays_between(@month_start, @month_end)
  end
   
  # TODO: implement
  def available?
    true
  end
      
  def billing_degree
    registered_billable_hours = @time_entries.billable.sum_hours
    if registered_billable_hours > 0
      ((registered_billable_hours / @expected_hours) * 100).round
    else
       0
    end
  end
  
  def balance
    if today > @month_end
      registered_hours = @time_entries.sum_hours
      registered_hours - @expected_hours
    elsif current_month?
      report_upto_date = find_report_upto_date
      if report_upto_date
        expected = WorkTimeCalculations.find_expected_workhours_between(@month_start, report_upto_date)
        actual = @time_entries.between(@month_start, report_upto_date).sum_hours
        actual - expected
      else
         0
      end
    else
      0
    end
  end
  
  private

  def current_month?
    @current_month ||= begin
      today.month == @month_start.month
    end
  end

  def find_report_upto_date
    if current_month?
      @time_entries.for_date(today).sum_hours > 0 ? today - 1 : today 
    elsif today > @month_end
      @month_end
    else
      nil
    end
  end

  def today
    @today ||= Time.zone.now.to_date
  end       
end