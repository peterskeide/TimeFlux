module ReportsHelper

  def render_table(table)
    if not table
      "please select"
    elsif is_empty? table
      "No data"
    else
      table.to_html()
    end
  end


  def render_hidden_hours_tags(params)
    " #{hidden_field_tag 'grouping',  params[:grouping]} \n
     #{hidden_field_tag 'sort_by',  params[:grouping]} \n
     #{hidden_field_tag 'page_break',  params[:page_break]} \n
     #{hidden_field_tag 'year',  params[:year]} \n
     #{hidden_field_tag 'month',  params[:month]} \n
     #{hidden_field_tag 'billed',  params[:billed]} \n
     #{hidden_field_tag 'user',  params[:user]} \n
     #{hidden_field_tag 'type',  params[:type]} "
  end

  def date_to_url(date)
    return {
      'calendar[date(1i)]' => date.year,
      'calendar[date(2i)]' => date.month,
      'calendar[date(3i)]' => 1
    }
  end

  def is_empty?(table)
    if not table
      true
    elsif table.is_a? Ruport::Data::Grouping then
      table.none?
    elsif table.is_a? Ruport::Data::Table then
      table.empty?
    end
  end


end
