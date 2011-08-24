class Billing

  def initialize(customers, date, hide_empty)
    @customers = customers
    @from = date.at_beginning_of_month
    @to = date.at_end_of_month
    @hide_empty = hide_empty
  end

  def billing_report_data
    
    data = []

    @customers.each do |customer|
      customer_total=0
      projects_data = []
      customer.projects.sort.each do |project|
        time_entries =  TimeEntry.billed(false).between(@from,@to).for_project(project).include_users.include_hour_types.all
        
        unless time_entries.empty?
          project_total = 0
          entries = []

          time_entries.group_by(&:user).each do |user,group1|
            group1.group_by(&:hour_type).each do |type,group2|

              sum = 0
              group2.each{|e| sum += e.hours}
              entries << [user,"#{type.name}",sum]
              project_total += sum
            end
          end

          projects_data << [project, project_total, entries]
          customer_total += project_total
        end
      end
      unless customer_total == 0 && @hide_empty
        data << [customer.name, customer_total, projects_data]
      end
    end
    data
  end
end
