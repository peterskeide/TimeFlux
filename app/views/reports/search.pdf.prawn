pdf.repeat :all, :at => pdf.margin_box.top_left do
  pdf.font "Helvetica" do
    pdf.text t('search.title'), :size => 20, :align => :center
    pdf.image "public/images/conduct-logo.png", :width => 100, :position => :right,  :vposition => 4
  end
end

pdf.repeat :all, :at => [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.font "Helvetica" do
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
    pdf.text "conduct 2009", :align => :center, :size => 12
  end
end

pdf.bounding_box [0, pdf.bounds.height - 80], :height =>  pdf.bounds.height - 120, :width => pdf.bounds.width do
  
  pdf.font "Helvetica" do
    pdf.text t('search.criteria'), :size => 11
    pdf.move_down(10)

    styled_parameters = @parameters.map { |name,value|
      [name, { :text => value, :font_style => :bold }] }

    pdf.table styled_parameters,
      :border_style => :underline_header,
      :padding => 2,
      :font_size => 10
    pdf.move_down(11)
  end

  if @time_entries.empty?
    pdf.move_down(40)
    pdf.text t('search.empty_result')
  else
  
    user_entries = @time_entries.group_by(&@group_by)
    user_entries.each do |group, te|

      entry_data = te.map do |t|
        [
          t.date,
          t.hours,
          t.notes
        ]
      end

      if pdf.cursor < 200 && entry_data.size * 50 > (pdf.cursor-50)
        pdf.start_new_page
      end

      pdf.move_down(30)
      pdf.font "Helvetica", :style => :bold do
        pdf.text case @group_by
        when :activity then group.customer_project_name
        when :user then group.name
        else group.to_s end
      end
      pdf.move_down(5)

      pdf.table entry_data,
        :row_colors => ["FFFFFF","f0f0f0"],
        :headers => [t('common.date'),t('common.hours'), t('common.notes') ],
        :align => { 0 => :left, 1 => :center},
        :column_widths => {0 => 70, 1 => 40},
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

