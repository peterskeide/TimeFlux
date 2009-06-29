class TimeEntriesFormBuilder < ActionView::Helpers::FormBuilder
  
  # Will return a disabled text field for time entries that are locked
  def lock_checking_text_field(method, options = {})
    text_field(method, options.merge({:disabled => self.object.locked}))
  end
  
end