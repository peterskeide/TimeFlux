class Activity < ActiveRecord::Base
  
  belongs_to :category
  has_many :week_entries
  has_many :time_entries, :through => :week_entries
  has_and_belongs_to_many :users
  
  private

  def validate_on_destroy
    if not week_entries.empty?
       errors.add_to_base("#{name} has registered hours - could not be removed")
    end 
  end

end