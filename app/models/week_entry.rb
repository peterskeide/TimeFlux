class WeekEntry < ActiveRecord::Base
  
  belongs_to :activity  
  belongs_to :user
  has_many :time_entries

  before_destroy :on_destroy

  accepts_nested_attributes_for :time_entries
  
  validates_presence_of :year, :week_number, :activity, :user
  validates_numericality_of :year, :week_number

  def hours
    self.time_entries.collect { |t| t.hours }.sum
  end


  private
  
  def validate_on_create
    if WeekEntry.find_by_year_and_week_number_and_activity_id_and_user_id(year, week_number, activity_id, user_id)
      errors.add_to_base("There is already a week entry for this activity")
    end
  end

  def on_destroy
    self.time_entries.each { |t| t.destroy }
  end
  
end