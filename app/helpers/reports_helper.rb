module ReportsHelper


  def render_table(table)
    if table.is_a? Ruport::Data::Grouping then
        return "No data" if table.none?
    elsif table.is_a? Ruport::Data::Table then
        return "No data" if table.empty?
    end
    return table.to_html()
  end

end
