

 class ReportConverter

  CONVERTER = Iconv.new( 'ISO-8859-15//IGNORE//TRANSLIT', 'utf-8')

  def self.convert(object)
    return nil unless object

    if object.is_a? Ruport::Data::Grouping
      convert_grouping(object)
    elsif object.is_a? Ruport::Data::Table
      convert_table(object)
    else
      begin
        CONVERTER.iconv(object)
      rescue
        puts "Conversion of class #{object.class} not supported"
        object
      end
      
    end
  end

  def self.convert_grouping(grouping)
    new_grouping = Ruport::Data::Grouping.new
    grouping.each() {|n,g|
        new_grouping << convert_group(g) if g
      }
    return new_grouping
  end

  def self.convert_group(group)
    Ruport::Data::Group.new( :name => convert_string(group.name),
      :data => convert_data(group.data),
      :column_names => convert_array(group.column_names) )
  end

  def self.convert_table(table)
    Ruport::Data::Table.new( :data => convert_data(table.data),
      :column_names => convert_array(table.column_names) )
  end

  def self.convert_data(data)
    converted_data = []
    data.each do |entry|
      converted_data << entry.collect do |field|
        CONVERTER.iconv(field.to_s)
      end
    end
    return converted_data
  end

  def self.convert_array(array)
    array.collect do |name|
      CONVERTER.iconv(name.to_s)
    end
  end

  def self.convert_string(string)
    CONVERTER.iconv(string.to_s)
  end
 end
