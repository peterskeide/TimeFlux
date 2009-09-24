module ReportsHelper

  def render_hidden_hours_tags(params)

    if params[:type] == "advanced"
      fields = %w{from_year to_year from_day from_month to_month to_day status user customer tag tag_type type}
    else
      fields = %w{year month customer}
    end

    hidden_fields = ""
    fields.each { |field| hidden_fields += hidden_field_tag(field, params[field.to_sym]) }
    hidden_fields
  end

  def date_to_url(date)
    return {
      'calendar[date(1i)]' => date.year,
      'calendar[date(2i)]' => date.month,
      'calendar[date(3i)]' => 1
    }
  end

end
