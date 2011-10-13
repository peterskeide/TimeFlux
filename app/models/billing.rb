class Billing

  def initialize(customers, date, show_empty)
    @customers = customers
    @from = date.at_beginning_of_month
    @to = date.at_end_of_month
    @show_empty = show_empty
  end


  def billing_report_data

    data = []
    
#    projects = Project.for_customer(@customers)
    
    # TODO use one query to improve efficiency
    #time_entries =  TimeEntry.between(@from,@to).for_projects(projects)

    add_report_data_for_projects(data, Project.find(:all, :conditions => "department_id IS NULL"), "No department")

    Department.all.each do |department|

      add_report_data_for_projects(data, department.projects, department.name)


#      projects = department.projects.select { |project| @customers.include?(project.customer) }
#
#      projects.group_by(&:customer).each do |customer,grouped_projects|
#
#        customer_total=0
#        projects_data = []
#
#        grouped_projects.each do |project|
#
#          time_entries =  TimeEntry.between(@from,@to).for_project(project).include_users.include_hour_types.all
#
#          unless time_entries.empty?
#            project_total = 0
#            entries = []
#
#            time_entries.group_by(&:user).each do |user,group1|
#              group1.group_by(&:hour_type).each do |type,group2|
#
#                sum = 0
#                group2.each{|e| sum += e.hours}
#
#                status_string = {}
#                group2.group_by(&:status).each do |status,group3|
#                  if group3.size > 0
#                    status_string.merge!({status => group3.size})
#                  end
#                end
#                billed = status_string
#
#                entries << [user,"#{type.name}",sum, billed]
#                project_total += sum
#              end
#            end
#
#            projects_data << [project, project_total, entries]
#            customer_total += project_total
#          end
#        end
#        unless customer_total == 0 && ! @show_empty
#          data << [department.name, customer.name, customer_total, projects_data]
#        end
#    end

    end

    


    return data
  end

  private

  def add_report_data_for_projects(data, project_list, group_name)
    projects = project_list.select { |project| @customers.include?(project.customer) }

    projects.group_by(&:customer).each do |customer,grouped_projects|

      customer_total=0
      projects_data = []

      grouped_projects.each do |project|

        time_entries =  TimeEntry.between(@from,@to).for_project(project).include_users.include_hour_types.all

        unless time_entries.empty?
          project_total = 0
          entries = []

          time_entries.group_by(&:user).each do |user,group1|
            group1.group_by(&:hour_type).each do |type,group2|

              sum = 0
              group2.each{|e| sum += e.hours}

              status_string = {}
              group2.group_by(&:status).each do |status,group3|
                if group3.size > 0
                  status_string.merge!({status => group3.size})
                end
              end
              billed = status_string

              entries << [user,"#{type.name}",sum, billed]
              project_total += sum
            end
          end

          projects_data << [project, project_total, entries]
          customer_total += project_total
        end
      end
      unless customer_total == 0 && ! @show_empty
        data << [group_name, customer.name, customer_total, projects_data]
      end
    end
  end

end
