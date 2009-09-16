# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def title
    title = "TimeFlux - "
    if controller.controller_name == "user_sessions"
      title +=  "the open and easy way of time management and billing"
    else
      title +=  controller.controller_name.gsub('_',' ').capitalize
      title += " - #{controller.action_name.gsub('_',' ').capitalize}" unless controller.action_name == "index"
    end
    return title
  end

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  
end