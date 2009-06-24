module TimeEntriesHelper  
  
  def date_label_for(object)
    #TODO this used to work????
    #"#{object.date} (#{object.date.cwday_to_s})"
    "#{object.date} (#{object.date.cwday})"
  end
  
end