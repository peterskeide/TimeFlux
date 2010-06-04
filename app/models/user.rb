class User < ActiveRecord::Base
  
  acts_as_authentic    
  
  has_many :time_entries
  has_and_belongs_to_many :projects
  has_many :activities, :through => :projects
     
  validates_presence_of :firstname, :lastname, :login
  validates_uniqueness_of :login
  
  before_destroy :validate_not_last_admin, :validate_has_no_projects, :validate_has_no_time_entries

  named_scope :active, :conditions => { :operative_status => "active" }

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def name
    self.fullname
  end

  def status_for_period(from_date, to_date, expected_days, expected_hours)
    hours = time_entries.between(from_date, to_date).sum(:hours)
    days = TimeEntry.distinct_dates.between(from_date, to_date).for_user(self).all.size
    unlocked_count = time_entries.between(from_date, to_date).locked(false).count

    if hours >= expected_hours && days >= expected_days && unlocked_count == 0
      return "green"
    end

    if hours >= expected_hours && days >= expected_days
      return "normal"
    end

    return "red"
  end
  
  def self.all_except(user_or_user_id)
    if user_or_user_id.is_a? User 
      user_id = user_or_user_id.id
    elsif user_or_user_id.is_a? Integer
      user_id = user_or_user_id
    else raise "user_or_user_id must be of type User or Integer"
    end
    User.all(:conditions => ["id != ?", user_id])
  end

  def status_for_month(date, expected_days, expected_hours)
    status_for_period(date, date.at_end_of_month, expected_days, expected_hours)
  end

  def self.status_values
    %w(active retired m.i.a.)
  end

  def hours_on_day(day)
    time_entries.on_day(day).sum(:hours)
  end

  def <=>(other)
    firstname <=> other.firstname
  end
  
  def update_vacation!(start_date, end_date, vacation_dates)
    configuration = Configuration.instance
    vacation = configuration.vacation_activity
    work_hours = configuration.work_hours
    hour_type = HourType.find_by_default_hour_type(true)
    vacation_dates = vacation_dates.collect { |d| d.is_a?(Date) ? d : Date.parse(d) }
    vacation_entries = time_entries.for_activity(vacation).between(start_date, end_date)
    vacation_entries.each { |te| te.destroy unless vacation_dates.include? te.date }
    remaining_vacation_dates = vacation_entries.collect { |te| te.date unless te.frozen? } # destroying an activerecord model will freeze it
    vacation_dates.each do |date|
      unless remaining_vacation_dates.include? date
        time_entries.create(:activity => vacation, :hour_type => hour_type, :date => date, :hours => work_hours)
      end
    end
  end
  
  # Returns a list of shared activities +
  # the activities assigned to the user
  def current_activities(date)
    current = projects.map{ |project| project.activities }.flatten
    current += Activity.active(true).default(true)
    current.uniq!
    current.sort! { |a, b| a.customer_project_name <=> b.customer_project_name }
    last_used = time_entries.all(:order => "created_at DESC", :limit => 1).first
    if last_used
      current = current.delete_if { |activity| activity.id == last_used.activity.id }
      current = current.unshift(last_used.activity)
    end
    current
  end
          
  private
  
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