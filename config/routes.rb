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
  get "/drug_threshold/unique_prescriptions"

  ###################### Main Controller ##############################

  get '/dashboard' => "main#dashboard"
  get "/main/about"
  get 'login' => "main#login"
  post 'login' => "main#login"
  get '/logout' => "main#logout"
  get '/pharmacy_sheet/:date' => "main#activity_sheet"
  get '/print_pharmacy_sheet/:date' => "main#print_activity_sheet"
  get '/main/contact'
  post '/main/contact'

  ###################### Rxnconso Controller ##############################
  get "/suggestions" => "rxnconso#suggestions"

  ###################### Prescription Controller ##############################
  get "/void_prescriptions/:id" => "prescription#destroy"
  get "/prescriptions" => "prescription#ajax_prescriptions"
  post "/refill" => "prescription#refill"
  post "/prescription/dispense"

  ###################### General Inventory Controller ##############################
  post "/void_general_inventory" => "general_inventory#destroy"
  get "/general_inventory/expired_items"
  get "/general_inventory/expiring_items"
  get "/general_inventory/understocked"
  get "/general_inventory/wellstocked"

  ###################### PMAP Inventory Controller ##############################

  get "/move_pmap_inventory/:id" => "pmap_inventory#move_inventory"
  get "/reorders" => "pmap_inventory#reorders"
  get "/expired_pmap_items" => "pmap_inventory#expired_items"
  get "/pmap_inventory/about_to_expire"
  post "/ajax_reorders" => "pmap_inventory#detailed_search"
  post "/pmap_inventory/edit"
  post "/void_pmap_inventory" => "pmap_inventory#destroy"

  ###################### Inventory Controller ##############################
  get "/print_bottle_barcode/:id" => "inventory#print_bottle_barcode"
  get "/print_dispensation_label/:id" => "inventory#print_dispensation_label"
  get "/void_item/:bottle_id" => "inventory#void_inventory_item"
  get "/move_item/:bottle_id" => "inventory#move_inventory_item"

  ###################### News Controller ##############################

  get "/ignore_message/:id" => "news#destroy"
  get "/manage_notice" => "news#manage_notice"

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
