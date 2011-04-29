pdf.header pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text t('invoice.title'), :size => 20, :align => :center
    pdf.image "public/images/conduct-logo.png", :width => 100, :position => :right,  :vposition => 4
  end
end

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.font "Helvetica" do
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
    pdf.text "Conduct #{Date.today.year}", :align => :center, :size => 12
  end
end

pdf.bounding_box [0, pdf.bounds.height - 80], :height =>  pdf.bounds.height - 120, :width => pdf.bounds.width do

  @projects.each do |project|

    user_entries = TimeEntry.billed(false).for_project(project).between(@from_day, @to_day).group_by(&:user)

    pdf.start_new_page unless project == @projects.first
  
    pdf.font "Helvetica" do
      [ "#{t('common.customer')}: #{project.customer.name}",
        "#{t('common.project')}: #{project.name}",
        "#{t('common.period')}: #{@day} - #{@day.at_end_of_month}"].each do |text_line|

        pdf.pad_bottom(3) do
          pdf.text text_line, :size => 11
        end
      end
    end

    user_entries.each do |user, te|

      entry_data = te.map do |t|
        [
          t.date,
          t.hour_type.name,
          t.hours,
          t.notes
        ]
      end

      if pdf.cursor < 200 && entry_data.size * 50 > (pdf.cursor-50)
        pdf.start_new_page
      end

      pdf.move_down(30)
      pdf.font "Helvetica", :style => :bold do
        pdf.text user.fullname
      end
      pdf.move_down(5)

      pdf.table entry_data.sort,
        :row_colors => ["FFFFFF","f0f0f0"],
        :headers => [t('common.date'), t('common.type'),t('common.hours'), t('common.notes') ],
        :align => { 0 => :left, 1 => :left, 2 => :center},
        :column_widths => {0 => 70, 1 => 70, 2 => 40},
        :width      => pdf.margin_box.width,
        :border_style => :underline_header,
        :font_size => 10,
        :padding => 2

      pdf.stroke_horizontal_rule
      pdf.move_down(10)
      pdf.text "#{t('common.total_hours')}: #{te.sum(&:hours)}", :align => :right
    end

  end
end
