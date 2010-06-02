class Date
      
  def holiday?
    Holiday.on_day(self).empty? ? false : true
  end
  
  def work_hours
    Holiday.expected_on_day(self)
  end
  
  def workday?
    self.work_hours > 0
  end
  
end