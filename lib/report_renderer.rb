require "ruport"

class ReportRenderer < Ruport::Controller
  stage :report

  formatter :html do
    build :report do
      output << textile("h1. Hi there")
    end
  end

  formatter :csv do
    build :report do
      build_row([1,2,3])
    end
  end

  formatter :pdf do
    build :report do
      add_text "hello world"
    end
  end

  formatter :text do
    build :report do
      output << "Hello world"
    end
  end
end
