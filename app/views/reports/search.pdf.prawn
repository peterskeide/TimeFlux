pdf.header pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text "Søkeresultat", :size => 20, :align => :center
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
  pdf.text "Søkekriterier", :size => 11
  pdf.move_down(10)
  pdf.table @parameters,
    :border_style => :underline_header,
    :padding => 2,
    :font_size => 10
  pdf.move_down(11)
end

entries = @time_entries.map do |t|
  [
    t.date,
    t.hours,
    "Normaltid",
    t.notes
  ]
end

pdf.table entries,
  :row_colors => ["FFFFFF","f0f0f0"],
  :headers => ['Dato','Timer', 'Type', 'Kommentar' ],
  :align => { 0 => :left, 1 => :center},
  :column_widths => {0 => 70, 1 => 40, 2 => 70},
  :width      => pdf.margin_box.width,
  :border_style => :underline_header,
  :font_size => 10,
  :padding => 2

pdf.stroke_horizontal_rule
pdf.move_down(10)
pdf.text "Total hours: #{@time_entries.sum(:hours)}", :align => :right

