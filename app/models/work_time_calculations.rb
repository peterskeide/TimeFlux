module WorkTimeCalculations
  def self.find_expected_workdays_between(start_date, end_date)
    (start_date..end_date).to_a.select { |date| date.workday? }.length
  end
  
  def self.find_expected_workhours_between(start_date, end_date)
    (start_date..end_date).to_a.map { |date| date.work_hours }.sum
  end    
end