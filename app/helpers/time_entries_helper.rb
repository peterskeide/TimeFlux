module TimeEntriesHelper
  
  Weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']  
  
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
  
  def each_activity(&block)
    activities = @time_entries.uniq_activities
    activities.each do |a|
      time_entries_for_activity = @time_entries.for_activity(a)
      week_total = time_entries_for_activity.sum_hours
      sum_per_day = {}
      each_weekday do |day, date| 
        sum_per_day[day] = time_entries_for_activity.for_date(date).sum_hours 
      end
      block.call(a, sum_per_day, week_total)
    end
  end
  
  def each_weekday(&block)
    Weekdays.each_with_index do |day, index|
      block.call(day, @date + index)
    end
  end
      
end