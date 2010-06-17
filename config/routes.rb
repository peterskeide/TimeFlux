ActionController::Routing::Routes.draw do |map|

  map.root :controller => "user_sessions", :action => "new"
  
  map.resource :configuration
  map.resources :holidays
  map.resources :projects, :collection => { :assign_to_users => :post, :remove_user_assignment => :post }

  map.resources :customers, :user_sessions, :time_entries, :users, :activities, :hour_types, :configurations, :tags, :tag_types

  map.resources :users do |user|
    user.resources :time_entries, :member => { :confirm_destroy => :delete, :cancel_edit => :get }, :collection => { :lock => :post, :refresh_totals => :get }
    user.resource :month_review, :only => [:show]
    user.resource :month_listing, :only => [:show]
    user.resources :vacations, :only => [:show, :edit, :update]
  end
  
  map.reports "reports", :controller => "reports"

  map.month_list "month/:action.:format", :controller => "month"

  map.reports "reports", :controller => "reports"
  map.reports "reports/:action.:format", :controller => "reports"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end