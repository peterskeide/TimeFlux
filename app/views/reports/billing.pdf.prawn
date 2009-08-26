#pdf.info = {
#    :Title => "My title", :Author => "John Doe", :Subject => "My Subject",
#    :Keywords => "test metadata ruby pdf dry", :Creator => "ACME Soft App",
#    :Producer => "Prawn", :CreationDate => Time.now, :Grok => "Test Property"
#  }


pdf.header pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text "Fakturagrunnlag", :size => 20, :align => :center
    pdf.image "public/images/conduct-logo.png", :width => 100, :position => :right,  :vposition => 4
    pdf.move_down(-10)
    #pdf.stroke_horizontal_rule
    pdf.move_down(20)

    ["Kunde: Kundenavn","Prosjekt: Prosjektnavn","Periode: fradato - tildato"].each do |text_line|
      pdf.pad_bottom(3) do
        pdf.text text_line, :size => 11
      end
    end
  end
end

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.font "Helvetica" do
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
    pdf.text "conduct 2009", :align => :center, :size => 12
    pdf.move_down(-14)
    pdf.text "Page: #{pdf.page_count}", :align => :right, :size => 11
  end
end

entries = @time_entries.map do |t|
  [
    t.date,
    t.hours,
    t.notes
  ]
end

pdf.bounding_box [0,600], :width => pdf.margin_box.width, :height => 550 do
  pdf.font "Helvetica", :style => :bold do
    pdf.text "Konsulentnavn"
  end
  pdf.move_down(5)
  #pdf.stroke_horizontal_rule

  pdf.table entries,
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
  pdf.text "Total hours: #{@time_entries.sum(:hours)}", :align => :right
end
