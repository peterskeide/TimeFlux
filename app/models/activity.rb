class Activity < ActiveRecord::Base

  has_many :time_entries
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags

  def to_s
    "Activity: #{name}"
  end

  private

  def validate_on_destroy
    if not week_entries.empty?
       errors.add_to_base("#{name} has registered hours - could not be removed")
    end 
  end

end