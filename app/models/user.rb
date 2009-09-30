class User < ActiveRecord::Base
  
  acts_as_authentic    
  
  has_many :time_entries
  has_and_belongs_to_many :projects
  has_many :activities, :through => :projects
     
  validates_presence_of :firstname, :lastname, :login
  validates_uniqueness_of :login
  
  before_destroy :validate_not_last_admin, :validate_has_no_projects, :validate_has_no_time_entries
  
  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def name
    self.fullname
  end

  def status_for_period(from_date, to_date, expected_days, expected_hours)
    hours = time_entries.between(from_date, to_date).sum(:hours)
    days = time_entries.between(from_date, to_date).distinct_dates.count
    unlocked_count = time_entries.between(from_date, to_date).locked(false).count

    if hours >= expected_hours && days >= expected_days && unlocked_count == 0
      return "ok"
    end

    if hours >= expected_hours
      return "warn"
    elsif days >= expected_days
      return "warn"
    end
    return "error"
  end

   def status_for_month(date, expected_days, expected_hours)
     status_for_period(date, date.at_end_of_month, expected_days, expected_hours)
  end

  def self.status_values
    %w(active retired m.i.a.)
  end

  def hours_on_day(day)
    entries = self.time_entries.on_day day
    hours = entries.collect{|t| t.hours}.sum
    if hours > 0 then hours.to_s else '-' end
  end

  def <=>(other)
    firstname <=> other.firstname
  end
  
  def update_vacation!(start_of_month, vacation_dates)
    end_of_month = start_of_month.end_of_month    
    activity = Configuration.instance.vacation_activity
    hour_type = HourType.find_by_default_hour_type(true)
    start_of_month.upto(end_of_month) do |day|
      if vacation_dates.try("[]".to_sym, day.to_s)
        current = time_entries.for_activity(activity).on_day(day)
        if current.empty?
          t = time_entries.create(:activity => activity, :hour_type => hour_type, :date => day, :hours => Configuration.instance.work_hours)
        end
      else
        current = time_entries.for_activity(activity).on_day(day)
        unless current.empty?
          current.first.destroy
        end
      end
    end
  end
  
  def vacation_total_for_month_of_year(month, year)
    month_start = Date.civil(year, month, 1)
    time_entries.for_activity(Configuration.instance.vacation_activity).between(month_start, month_start.at_end_of_month).count
  end
  
  def vacation_total_for_year(year)
    time_entries.for_activity(Configuration.instance.vacation_activity).between(Date.civil(year, 1,1), Date.civil(year + 1, 1, 1) -1).count
  end
  
  # Returns a list of shared activities +
  # the activities assigned to the user
  def current_activities(date)
    current = projects.map{ |project| project.activities }.flatten
    current = sort_by_most_used_activity(date, current.uniq)
    current += Activity.active(true).default(true)
    current
  end
    
  private
  
  def sort_by_most_used_activity(date, activities)
    start_date = date - 7
    activity_count = Hash.new(0)
    activities.each do |a|
      count = time_entries.between(start_date, date).all(:conditions => ["activity_id = :aid", { :aid => a.id }]).length
      activity_count[a] = count
    end
    activity_count.sort { |a,b| a[1] <=> b[1] }.collect { |ac| ac[0] }.reverse
  end
  
  def validate_not_last_admin
    if admin && User.find_all_by_admin(true).size == 1 then
      errors.add_to_base('Cannot not remove last admin user')
      return false
    end
  end
  
  def validate_has_no_projects
    if projects.size > 0 then
      errors.add_to_base('User is assigned to one or more projects')
      return false
    end
  end
  
  def validate_has_no_time_entries
    if time_entries.size > 0 then
      errors.add_to_base('User has time entries')
      return false
    end
  end

end