require 'net/ldap'

class User < ActiveRecord::Base
  
  has_many :time_entries
  has_and_belongs_to_many :activities
     
  validates_presence_of :firstname, :lastname, :login
  validates_uniqueness_of :login
  
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
    self.activities + Activity.active(true).default(true)
  end

  #def to_s
  #  "#{self.fullname} (id=#{self.object_id})"
  #end

end