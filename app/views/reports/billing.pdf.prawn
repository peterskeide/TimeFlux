pdf.header pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text "Fakturagrunnlag", :size => 20, :align => :center
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

@projects.each do |project|

  user_entries = TimeEntry.for_project(project).between(@from_day, @to_day).group_by(&:user)

  pdf.start_new_page unless project == @projects.first
  pdf.move_down(60)
  
  pdf.font "Helvetica" do
    [ "Kunde: #{project.customer.name}",
      "Prosjekt: #{project.name}",
      "Periode: #{@day} - #{@day.at_end_of_month}"].each do |text_line|

      pdf.pad_bottom(3) do
        pdf.text text_line, :size => 11
      end
    end
  end

  user_entries.each do |user, te|

    entry_data = te.map do |t|
    [
      t.date,
      t.hours,
      t.notes
    ]
    end

  #pdf.bounding_box [0,600], :width => pdf.margin_box.width, :height => 550 do
    pdf.move_down(30)
    pdf.font "Helvetica", :style => :bold do
      pdf.text user.fullname
    end
    pdf.move_down(5)
    #pdf.stroke_horizontal_rule

    pdf.table entry_data,
      :row_colors => ["FFFFFF","f0f0f0"],
      :headers => ['Dato', 'Timer', 'Kommentar' ],
      :align => { 0 => :left, 1 => :center},
      :column_widths => {0 => 70, 1 => 40},
      :width      => pdf.margin_box.width,
      :border_style => :underline_header,
      :font_size => 10,
      :padding => 2

    pdf.stroke_horizontal_rule
    pdf.move_down(10)
    pdf.text "Total hours: #{te.sum(&:hours)}", :align => :right
  end


end
