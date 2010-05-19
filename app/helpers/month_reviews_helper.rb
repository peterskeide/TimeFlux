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

  def calendar_day_formatted(inner_tag, expected_hours, current_day)
    html =  ""
    if expected_hours == 0
      html += '<span style="color: red;">'
    else
      html += '<span>'
    end

    html += current_day ?  "<u>#{inner_tag.to_s}</u>" : "#{inner_tag.to_s}"
    html += '</span>'
  end

end
