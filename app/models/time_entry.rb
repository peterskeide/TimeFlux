class TimeEntry < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :activity
  
  validates_numericality_of :hours, :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 24.0
  validates_format_of :hours, :with => /^[\d|.|,]*$/
  validate_on_update :must_not_be_locked
  
  named_scope :on_day, lambda { |day|
    {  :conditions => ['date = ?', day ] }
  }

  named_scope :for_user, lambda { |user_id|
    { :conditions => { :user_id => user_id } }
  }

  named_scope :billed, lambda { |billed|
    { :conditions => { :billed => billed } }
  }

  named_scope :between, lambda { |*args|
    {  :conditions => ['date between ? and ?', args.first, args.second] }
  }

  named_scope :for_activity, lambda { |*activity_ids|
    {  :conditions =>  ["activity_id IN (?)", activity_ids ] }
  }
  
  def self.search(day, activities, user, billed)
    search = ["TimeEntry"]
    search << "for_activity(#{activities.collect { |a| a.id }.join(',')})" unless activities.blank?
    search << "for_user(#{user.id})" unless user.blank?
    search << "billed(#{billed})" unless billed.blank?
    #search << "paginate(:page => #{page}, :per_page => 10, :order => 'activities.name')"
    query = search.join(".")

    logger.debug("Time entry Search Query: #{query}")
    (eval query).between(day,(day >> 1) -1)
  end

  def self.mark_as_billed(time_entries)
    logger.debug "Marking up to #{time_entries.size} time_entries as billed!"
    time_entries.each do |t|
      unless t.billed
        t.billed = true
        t.save
        logger.debug "#{t}, marked as billed"
      end
    end
  end
  
  def <=>(other)
    date <=> other.date
  end

  def to_s
    "#{self.hours} hours on date #{self.date}"
  end

  def hours_to_s
    if self.hours > 0 then self.hours.to_s else '-' end
  end

  private
  
  def must_not_be_locked
    if changed?
      errors.add_to_base("Updating locked time entries is not possible") if locked
    end
  end
  
end