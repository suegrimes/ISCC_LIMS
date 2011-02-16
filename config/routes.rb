ActionController::Routing::Routes.draw do |map|
  map.resources :samples


  map.connect '', :controller => "welcome", :action => "index" 
  map.signup  '/signup', :controller => 'users',   :action => 'new' 
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # User tables, and other administrative tables
  map.resources :users
  map.forgot    '/forgot',                    :controller => 'users',     :action => 'forgot'
  map.activate  'activate/:activation_code',  :controller => 'users',     :action => 'activate'
  map.reset     'reset/:reset_code',          :controller => 'users',     :action => 'reset'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
