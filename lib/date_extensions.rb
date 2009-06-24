class Date
   
  def cwday_to_s
    case cwday
    when 1 then "Monday"
    when 2 then "Tuesday"
    when 3 then "Wednesday"
    when 4 then "Thursday"
    when 5 then "Friday"
    when 6 then "Saturday"
    when 7 then "Sunday"
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