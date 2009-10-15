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

end
