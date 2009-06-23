require "ruport"



 class TestController < Ruport::Controller

    stage :report

   #required_option :title

    formatter :html do
      build :report do
        output << textile("h1. #{options.title}")
        output << data.to_html(:style => :justified)
      end
    end

    formatter :csv do
      build :report do
        output << data.to_csv
      end
    end

    formatter :pdf do
      build :report do
        add_text options.title
        draw_table data
        #pad_bottom(20) do
        #  add_text "footer goes here"
        #end
      end
    end

    formatter :text do
      build :report do
        output << "#{options.title}\n\n"
        output << data.to_text
      end
    end
 end
