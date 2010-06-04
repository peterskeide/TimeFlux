module MonthReviewsHelper  
  def activities_list(activities_summary)
    sum = 0
    html = ""
    activities_summary.each do |entry|
      html += "<tr>"
      html += "<td>#{entry[:name]}</td>"
      html += "<td style=\"text-align:right\">#{entry[:hours]}</td>"
      html += "</tr>"
      sum += entry[:hours]
    end

    if sum > 0
      html += "<tr>
      <th class=\"overline\">
        Total:
      </th>
      <th class=\"overline\" style=\"text-align:right; min-width:3em;\">
        #{sum}
      </th>
    </tr>"
    end
  end
  
  def hours_for_day(workday)
    total_hours = workday.total_hours
    total_hours_or_dash = total_hours > 0 ? total_hours : '-'
    result = workday.in_reported_month? ? "<td>" : "<td style='color: #E0E0E0;'>"
    result << (workday.today? ? "<u>#{total_hours_or_dash}</u>" : "#{total_hours_or_dash}")
    result << "</td>"
  end
   
  def registered_and_expected_hours(statistics)
    registered_hours = statistics.registered_hours
    expected_hours = statistics.expected_hours
    hours_color = registered_hours >= expected_hours ? '' : 'warn'
    "Hours: <span class=\'#{hours_color}\'>#{registered_hours}</span> / #{expected_hours}"
  end
  
  def registered_and_expected_days(statistics)
    registered_days = statistics.registered_days
    expected_days = statistics.expected_days
    days_color = registered_days >= expected_days ? '' : 'warn'
    "days: <span class=\'#{days_color}\'>#{registered_days}</span> / #{expected_days}"
  end
end
