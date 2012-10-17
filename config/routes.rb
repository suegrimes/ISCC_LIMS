ActionController::Routing::Routes.draw do |map|
  
  # Login/logout, and signup
  map.connect '',     :controller => 'welcome', :action => 'index' 
  map.signup  '/signup', :controller => 'users',   :action => 'new' 
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # User tables, and other administrative tables
  map.resources :sessions
  map.resources :auth_users
  map.resources :users
  map.forgot    'forgot',                     :controller => 'users',     :action => 'forgot'
  map.activate  'activate/:activation_code',  :controller => 'users',     :action => 'activate'
  map.reset     'reset/:reset_code',          :controller => 'users',     :action => 'reset'
  
  # Sample tables
  map.resources :samples, :collection => {:auto_complete_for_strain => :get,
                                          :auto_complete_for_intestinal_sc_marker => :get,
                                          :auto_complete_for_sc_marker_validation_method => :get,
                                          :shipment_confirm => :get,
                                          :sample_ship => :get}
                                          
  map.recv_samples 'list_intransit',             :controller => :samples, :action => :list_intransit
  map.show_sop     'show_sop',                   :controller => :samples, :action => :show_sop
  map.sample_results 'sample_results',           :controller => :samples, :action => :show_results
  
  # Sequencing Runs/Lanes/QC
  #map.resources :seq_runs
  #map.resources :seq_lanes
  #map.resources :seq_qc

  # Result Files
  map.resources :result_files
  map.show_rdef  'show_rdef',      :controller => 'result_files', :action => 'show_rdef'
  map.choose_lab 'choose_lab',     :controller => 'result_files', :action => 'choose_lab'
  map.edit_multi 'edit_multi',     :controller => 'result_files', :action => 'edit_multi'
  map.update_multi 'update_multi', :controller => 'result_files', :action => 'update_multi'
  #map.fastqc_show 'fastqc_show',   :controller => 'result_files', :action => 'fastqc_show'
  map.destroy 'destroy',           :controller => 'result_files', :action => 'destroy'
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
