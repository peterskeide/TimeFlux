require 'net/ldap'

class User < ActiveRecord::Base
  
  has_many :time_entries
  has_and_belongs_to_many :activities
  
  accepts_nested_attributes_for :time_entries
    
  acts_as_authentic { |c| c.validate_password_field = false }
   
  validates_presence_of :firstname, :lastname, :login
  validates_uniqueness_of :login

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def self.status_values
    %w(active retired m.i.a.)
  end

  def hours_total
    total = "hours:"
    self.time_entries.each { |i| puts i.hours }
    return total
  end

  def hours_on_day(day)
    entries = self.time_entries.on_day day
    hours = entries.collect{|t| t.hours}.sum
    if hours > 0 then hours.to_s else '-' end
  end

  def to_s
    "#{self.fullname} (id=#{self.object_id})"
  end
  
  def update_from_ldap
    ldap = Net::LDAP.new
    ldap.host = "jokke.conduct.no"
    ldap.auth 'uid=timeflux,ou=systems,dc=conduct,dc=no', 'password_goes_here'
    entry = ldap.search(:base => "ou=people,dc=conduct,dc=no", :filter => "(uid=#{login})")[0]
    self.firstname = entry.givenname[0]
    self.lastname = entry.sn[0]
    self.email = entry.mail[0]
    self.save
  end  

  protected

  def valid_ldap_credentials?(password_plaintext)
    ldap = Net::LDAP.new
    ldap.host = "jokke.conduct.no"
    ldap.auth "uid=#{self.login},ou=people,dc=conduct,dc=no", password_plaintext
    ldap.bind # will return false if authentication is NOT successful
  end

end