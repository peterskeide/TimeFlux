pdf.header pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text "Timer for #{@user.name}", :size => 20, :align => :center
    pdf.image "public/images/conduct-logo.png", :width => 100, :position => :right,  :vposition => 4
  end
end

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.font "Helvetica" do
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
    pdf.text "conduct 2009", :align => :center, :size => 12
  end
end

pdf.move_down(60)
  
pdf.font "Helvetica" do
  pdf.pad_bottom(3) do
    pdf.text "Periode: #{@beginning_of_month} - #{@end_of_month}", :size => 11
  end
end

@time_entries.each do |activity, te|

  entry_data = te.map do |t|
    [
      t.date,
      t.hour_type.name,
      t.hours,
      t.notes
    ]
  end

  if pdf.cursor < 150
    pdf.start_new_page unless entry_data.size < 5
  end

  pdf.move_down(30)
  pdf.font "Helvetica", :style => :bold do
    pdf.text activity.name
  end
  pdf.move_down(5)

  pdf.table entry_data,
    :row_colors => ["FFFFFF","f0f0f0"],
    :headers => ['Dato', 'Type','Timer', 'Kommentar' ],
    :align => { 0 => :left, 1 => :left, 2 => :center},
    :column_widths => {0 => 70, 1 => 70, 2 => 40},
    :width      => pdf.margin_box.width,
    :border_style => :underline_header,
    :font_size => 10,
    :padding => 2

  pdf.stroke_horizontal_rule
  pdf.move_down(10)
  pdf.text "Total hours: #{te.sum(&:hours)}", :align => :right
end