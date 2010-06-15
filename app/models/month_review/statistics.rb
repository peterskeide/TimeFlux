class MonthReview::Statistics   
  def initialize(time_entry_enumerable, month_start, month_end, today)
    @month_start = month_start 
    @month_end = month_end
    @time_entries = time_entry_enumerable
    @today = today
  end
   
  def available?
    !@time_entries.empty?
  end
  
  def registered_hours
    @time_entries.sum_hours
  end
  
  def registered_days
    @time_entries.sum_days
  end
  
  def expected_hours
     WorkTimeCalculations.find_expected_workhours_between(@month_start, @month_end)
  end
  
  def expected_days
    WorkTimeCalculations.find_expected_workdays_between(@month_start, @month_end)
  end
      
  def billing_degree
    registered_billable_hours = @time_entries.sum_billable_hours
    if registered_billable_hours > 0
      ((registered_billable_hours.to_f / expected_hours.to_f) * 100).round
    else
       0
    end
  end
  
  def balance
    if @today > @month_end
      registered_hours - expected_hours
    elsif current_month?
      report_upto_date = find_report_upto_date
      if report_upto_date
        expected = WorkTimeCalculations.find_expected_workhours_between(@month_start, report_upto_date)
        actual = @time_entries.sum_hours_between(@month_start, report_upto_date)
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
      @today.month == @month_start.month
    end
  end

  def find_report_upto_date
    if current_month?
      @time_entries.sum_hours_on_date(@today) > 0 ? @today : @today - 1
    else
      nil
    end
  end
       
end