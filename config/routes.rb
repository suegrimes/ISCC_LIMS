ISCCLims::Application.routes.draw do
  
  # Login/logout, and signup
  match '' => 'welcome#index'
  match '/signup' => 'users#new', :as => :signup
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  # User tables, and other administrative tables  
  resources :sessions
  resources :auth_users
  resources :users
  match 'forgot' => 'users#forgot', :as => :forgot
  match 'activate/:activation_code' => 'users#activate', :as => :activate
  match 'reset/:reset_code' => 'users#reset', :as => :reset

  # Sample tables  
  resources :samples do
    collection do
      get :auto_complete_for_strain
      get :auto_complete_for_intestinal_sc_marker
      get :auto_complete_for_sc_marker_validation_method
      get :shipment_confirm
      get :sample_ship
    end    
  end
  
  match 'list_intransit' => 'samples#list_intransit', :as => :recv_samples
  match 'show_sop' => 'samples#show_sop', :as => :show_sop
  match 'sample_results' => 'samples#show_results', :as => :sample_results
  
  # Result Files  
  resources :result_files
  match 'show_rdef' => 'result_files#show_rdef', :as => :show_rdef
  match 'choose_lab' => 'result_files#choose_lab', :as => :choose_lab
  match 'edit_multi' => 'result_files#edit_multi', :as => :edit_multi
  match 'update_multi' => 'result_files#update_multi', :as => :update_multi
  match 'destroy' => 'result_files#destroy', :as => :destroy
  match '/:controller(/:action(/:id))'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
