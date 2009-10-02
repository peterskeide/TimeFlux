module TimeEntriesHelper
  
  Weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']  
  
  def date_label_for(object)
    "#{Weekdays[object.date.wday - 1]} #{object.date.mday}"
  end
  
  def ids_from(models)
    models.collect { |model| model.id }
  end
  
  def select_by_activity(time_entries, activity)
    time_entries.select { |te| te.activity == activity }.sort
  end
  
  def time_entries_heading 
      content_tag(:h1, @current_user.admin ? "Time Entries for #{h @user.fullname}" : "Time Entries")
  end
  
  def weekdays
    Weekdays
  end
      
end