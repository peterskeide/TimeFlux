class Date
   
  def cwday_to_s
    case cwday
    when 1: return "Monday"
    when 2: return "Tuesday"
    when 3: return "Wednesday"
    when 4: return "Thursday"
    when 5: return "Friday"
    when 6: return "Saturday"
    when 7: return "Sunday"
    end
  end

  def self.week_of_date(date)
    monday = date.beginning_of_week
    {
      :monday => monday, 
      :tuesday => monday.+(1), 
      :wednesday => monday.+(2), 
      :thursday => monday.+(3), 
      :friday => monday.+(4), 
      :saturday => monday.+(5), 
      :sunday => monday.+(6)
    }
  end
     
end