class UserWorkWeek
  
  DAYNAMES = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
    
  def initialize(user_id, week_start_date)
    @user_id, @week_start_date = user_id, week_start_date
  end
  
  def entries_for_day(day_index)
    TimeEntry.find_all_by_user_id_and_date(@user_id, @week_start_date.+(day_index)).sort { |e1, e2| e1.activity.name <=> e2.activity.name }
  end
  
  def day_total(day_index)
    TimeEntry.sum("hours", :conditions => 
      [ "user_id = :user_id AND date = :date", 
      { :user_id => @user_id, :date => @week_start_date.+(day_index) } ])     
  end
  
  def week_total
    TimeEntry.sum("hours", :conditions => 
      [ "user_id = :user_id AND date >= :start_date AND date <= :end_date", 
      { :user_id => @user_id, :start_date => @week_start_date, :end_date => @week_start_date.+(6) } ])     
  end
  
end