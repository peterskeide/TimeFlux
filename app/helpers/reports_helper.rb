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
