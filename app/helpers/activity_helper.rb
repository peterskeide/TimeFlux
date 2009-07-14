module ActivityHelper
  
  def boolean_options
    {"any" => "", "true" => "true", "false" => "false"}
  end
  
  def empty_option(text = "")
    "<option value=''>#{text}</option>"
  end
  
end                  