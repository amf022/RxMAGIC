Rails.application.routes.draw do

  root 'main#index'

  ###################### Patient Controller ##############################
  get 'patient/new'

  get 'patient/create'

  get 'patient/destroy'

  get 'patient/show'

  get 'patient/index'

  post '/patient/ajax_patient'

  get '/patient/toggle_language_preference'


  ###################### Drug Threshold Controller ##############################
  get '/void_threshold/:id' => 'drug_threshold#destroy'
  get "/drug_threshold/unique_prescriptions"

  ###################### Manufacturer Controller ######################
  get '/void_manufacturer/:id' => 'manufacturer#destroy'

  ###################### Main Controller ##############################

  get '/dashboard' => "main#dashboard"
  get "/main/about"
  get "main/faq"
  get '/pharmacy_sheet/:date' => "main#activity_sheet"
  get '/print_pharmacy_sheet/:date' => "main#print_activity_sheet"
  get '/printable_activity_sheet/:date' => "main#printable_activity_sheet"
  get '/custom_report' => "main#custom_report"
  post '/report' => "main#custom_report"
  get '/main/contact'
  post '/main/contact'

  ###################### Rxnconso Controller ##############################
  get "/suggestions" => "rxnconso#suggestions"
  get "/threshold_suggestions" => "rxnconso#threshold_suggestions"
  get "/drug_mapping/:id" => "rxnconso#map_drug"
  get "/drug_mapping" => "rxnconso#drug_mapping"
  post "/map_drug" => "rxnconso#map_drug"
  ###################### Prescription Controller ##############################
  get "/void_prescriptions/:id" => "prescription#destroy"
  get "/prescriptions" => "prescription#ajax_prescriptions"
  get "/prescription/refill"
  post "/prescription/dispense"
  post "/prescription/edit"

  ###################### General Inventory Controller ##############################
  post "/void_general_inventory" => "general_inventory#destroy"
  post "/edit_general_inventory" => "general_inventory#edit"
  get "/general_inventory/expired_items"
  get "/general_inventory/expiring_items"
  get "/general_inventory/understocked"
  get "/general_inventory/wellstocked"
  get "view_gn_drug/:id" => "general_inventory#view_drug"
  get "/mfn_suggestions" => "general_inventory#mfn_suggestions"

  ###################### PMAP Inventory Controller ##############################

  get "/move_pmap_inventory/:id" => "pmap_inventory#move_inventory"
  get "/reorders" => "pmap_inventory#reorders"
  get "/expired_pmap_items" => "pmap_inventory#expired_items"
  get "/pmap_inventory/about_to_expire"
  get "/underutilized_pmap" => "pmap_inventory#underutilized"
  post "/ajax_reorders" => "pmap_inventory#detailed_search"
  post "/pmap_inventory/edit"
  post "/void_pmap_inventory" => "pmap_inventory#destroy"

  ###################### Inventory Controller ##############################
  get "/print_bottle_barcode/:id" => "inventory#print_bottle_barcode"
  get "/print_dispensation_label/:id" => "inventory#print_dispensation_label"
  get "/void_item/:bottle_id" => "inventory#void_inventory_item"
  get "/move_item/:bottle_id" => "inventory#move_inventory_item"
  get "/add_to_activity_sheet/:drug" => "inventory#add_to_activity_sheet"
  get "/inventory/add_to_activity_sheet"

  ###################### News Controller ##############################

  get "/ignore_message/:id" => "news#destroy"
  post "/manage_notice" => "news#manage_notice"
  get "/alert_to_activity_sheet/:id" => "news#alert_add_to_activity_sheet"

  ###################### User Role Controller #############################
  get 'user/index'
  get 'user/show'
  get 'user/new'
  get 'user/edit'
  get "/new_user_role" => "user#create_user_role"
  post "/new_user_role" => "user#create_user_role"
  get 'login' => "user#login"
  post 'login' => "user#login"
  get '/logout' => "user#logout"
  post '/void_dispensation' => "dispensation#destroy"

  ################# Disnpensation Controller ############################

  post "/refill" => "dispensation#refill"
  post "/void_dispensation" => "dispensation#destroy"

  resources :general_inventory
  resources :pmap_inventory
  resources :drug_threshold
  resources :patient
  resources :prescription
  resources :main
  resources :news
  resources :user
  resources :dispensation
  resources :manufacturer
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
