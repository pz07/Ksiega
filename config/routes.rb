ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  map.resource :accounts
  
  map.resources :users
  
  map.resource :user_session
  
  map.resource :transes
  
  map.resource :categories
  
  map.resource :statses

  map.resource :statements
  
  map.root :controller => "stats", :action => "all"

  map.logout 'logout', :controller => "user_sessions", :action => "destroy"
    
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  #main page
  #map.connect '', :controller => 'stats', :action => 'all'

  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
