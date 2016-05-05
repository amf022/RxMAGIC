Rails.application.routes.draw do

  root 'main#index'

  ###################### Patient Controller ##############################
  get 'patient/new'

  get 'patient/create'

  get 'patient/destroy'

  get 'patient/show'

  get 'patient/index'

  post '/patient/ajax_patient'


  ###################### Drug Threshold Controller ##############################
  get '/void_threshold/:id' => 'drug_threshold#destroy'

  ###################### Main Controller ##############################

  get '/dashboard' => "main#dashboard"
  get "/main/about"

  ###################### Rxnconso Controller ##############################
  get "/suggestions" => "rxnconso#suggestions"

  ###################### Prescription Controller ##############################
  get "/void_prescriptions/:id" => "prescription#destroy"
  get "/prescriptions" => "prescription#ajax_prescriptions"
  post "/refill" => "prescription#refill"

  ###################### General Inventory Controller ##############################
  post "/void_general_inventory" => "general_inventory#destroy"

  ###################### PMAP Inventory Controller ##############################
  post "/void_pmap_inventory" => "pmap_inventory#destroy"
  get "/move_pmap_inventory/:id" => "pmap_inventory#move_inventory"
  get "/reorders" => "pmap_inventory#reorders"
  post "/ajax_reorders" => "pmap_inventory#detailed_search"

  ###################### Inventory Controller ##############################
  get "/print_bottle_barcode/:id" => "inventory#print_bottle_barcode"

  ###################### News Controller ##############################

  get "/ignore_message/:id" => "news#destroy"

  resources :general_inventory
  resources :pmap_inventory
  resources :drug_threshold
  resources :patient
  resources :prescription
  resources :main
  resources :news

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
