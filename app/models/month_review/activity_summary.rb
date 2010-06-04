class MonthReview::ActivitySummary  
  attr_reader :billable, :unbillable
  
  def initialize(time_entry_enumerable)
    @time_entries = time_entry_enumerable
    @activities = @time_entries.uniq_activities
    @billable = []
    @unbillable = []
    initialize_billable_and_unbillable_activity_summaries
  end
  
  private
  
  def initialize_billable_and_unbillable_activity_summaries
    @activities.sort.each do |activity| 
      entry = {
        :name => activity.customer_project_name(50),
        :hours => @time_entries.for_activity(activity).sum_hours
        }
      activity.billable? ? @billable << entry : @unbillable << entry
    end
  end       
end