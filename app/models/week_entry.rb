class WeekEntry < ActiveRecord::Base
  
  belongs_to :activity  
  belongs_to :person
  has_many :time_entries
  
  accepts_nested_attributes_for :time_entries
  
  validates_presence_of :year, :week_number, :activity
  validates_numericality_of :year, :week_number
  
  private
  
  def validate_on_create
    if WeekEntry.find_by_year_and_week_number_and_activity_id(year, week_number, activity_id)
      errors.add_to_base("There is already a week entry for this activity")
    end
  end
  
end