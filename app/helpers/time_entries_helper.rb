module TimeEntriesHelper  
  
  def date_label_for(object)
    "#{object.date} (#{object.date.cwday_to_s})"
  end
  
end