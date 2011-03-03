class VacationOverview
  
  def initialize(year, user)
    @users = User.all(:select => "id, firstname, lastname", :order => "firstname", :conditions => ["operative_status = 'active' AND id != ?", user.id]).unshift(user)
    activity_id = Configuration.instance.activity.id
    vacation_entries = TimeEntry.all(:select => "user_id, date", :conditions => ["activity_id = ? and date >= ? and date <= ?", activity_id, Date.new(year,1,1), Date.new(year,12,31)])
    create_users_totals(vacation_entries)    
  end
  
  private_class_method :new
  
  def self.for_year_and_user(year, user)
    new(year, user)
  end
  
  def each_user_with_month_and_year_totals(&block)
     @users.each do |user|
       yield user, total_vacation_per_month_for_user(user), total_vacation_for_user(user)
     end
  end

  private
  
  def create_users_totals(vacation_entries)
    @users_totals = {}
    @users.each do |user|
      month_totals = [nil, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      year_total = 0
      user_vacation_entries = vacation_entries.select { |ve| ve if ve.user_id == user.id }
      user_vacation_entries.each do |uve|
        month_totals[uve.date.month] += 1
        year_total += 1
      end
      @users_totals[user] = { :month_totals => month_totals, :year_total => year_total }
    end
  end
  
  def total_vacation_per_month_for_user(user)
    @users_totals[user][:month_totals]
  end
  
  def total_vacation_for_user(user)
    @users_totals[user][:year_total]
  end
  
end