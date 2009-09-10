require 'net/ldap'

class User < ActiveRecord::Base
  
  has_many :time_entries
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :projects
     
  validates_presence_of :firstname, :lastname, :login
  validates_uniqueness_of :login
  
  before_destroy :validate_not_last_admin, :validate_has_no_projects, :validate_has_no_time_entries
  
  if TimeFlux::CONFIG.use_ldap
        
    acts_as_authentic { |c| c.validate_password_field = false }

    def valid_ldap_credentials?(password_plaintext)
      ldap = Net::LDAP.new
      ldap.host = TimeFlux::CONFIG.ldap_host
      base = TimeFlux::CONFIG.ldap_base
      auth_str = "uid=" + self.login + ",#{base}"
      ldap.auth auth_str, password_plaintext
      ldap.bind # will return false if authentication is NOT successful
    end

    private :valid_ldap_credentials?
    
  else
    acts_as_authentic    
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def name
    self.fullname
  end

  def status_for_period(from_date, to_date, expected_days, expected_hours)
    hours = TimeEntry.for_user(self).between(from_date, to_date).sum(:hours)
    days = TimeEntry.for_user(self).between(from_date, to_date).distinct_dates.count
    unlocked_count = TimeEntry.for_user(self).between(from_date, to_date).locked(false).count

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
    lastname <=> other.lastname
  end
  
  # Returns a list of shared activities +
  # the activities assigned to the user
  def current_activities
    current = self.activities + Activity.active(true).default(true)
    current += self.projects.map{|project| project.activities }.flatten
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