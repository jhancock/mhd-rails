Rails.application.routes.draw do

  root 'public#index'

  get 'login' => 'account_public#login', as: 'login'
  post 'login' => 'account_public#login_post'
  get 'logout' => 'account#logout', as: 'logout'
  #TODO get login_help correct.
  get 'login_help' => 'account_public#login_help', as: 'login_help'
  get 'register' => 'account_public#register', as: 'register'
  post 'register' => 'account_public#register_post'
  get 'account/email_verify/:code' => 'account#email_verify', as: 'email_verify'
  get 'account/email_verify_notice' => 'account#email_verify_notice', as: 'email_verify_notice'

  get 'account' => 'account#index', as: 'account_home'
  get 'account/change_password' => 'account#change_password', as: 'change_password'
  post 'account/change_password' => 'account#change_password_post'
  get 'account/change_email' => 'account#change_email', as: 'change_email'
  post 'account/change_email' => 'account#change_email_post'

  get 'password_reset_request' => 'account_public#password_reset_request', as: 'password_reset_request'
  post 'password_reset_request' => 'account_public#password_reset_request_post'  
  get 'password_reset/:code' => 'account_public#password_reset', as: 'password_reset'
  post 'password_reset/:code' => 'account_public#password_reset_post'

  get 'bookmarks(/page/:page)' => 'bookmarks#index', as: 'bookmarks'
  get 'bookmarks/:bookmark_id/delete' => 'bookmarks#delete', as: 'delete_bookmark'

  #TODO handle search with no query or no results
  get 'search(/:query)(/page/:page)' => 'search#search', as: 'search'

  get 'privacy_policy' => 'public#privacy_policy', as: 'privacy_policy'
  get 'terms_of_service' => 'public#terms_of_service', as: 'terms_of_service'
  get 'contact' => 'public#contact'
  get 'public/upload_notice' => 'public#upload_notice'

  get 'admin' => 'admin#index', as: 'admin'
  get 'admin/users' => 'admin_users#index', as: 'admin_users'
  get 'admin/users/search' => 'admin_users#search', as: 'admin_users_search'
  post 'admin/users/search' => 'admin_users#search_post'
  get 'admin/users/:id/show' => 'admin_users#show', as: 'admin_users_show'
  get 'admin/users/:id/remove' => 'admin_users#remove', as: 'admin_users_remove'
  post 'admin/users/:id/remove' => 'admin_users#remove_post'

  get 'tags/:tag(/:sort)(/page/:page)' => 'books#tag', as: 'books_by_tag', constraints: { sort: /recent|popular/ }
  get 'books(/:sort)(/page/:page)' => 'books#list', as: 'list_books', constraints: { sort: /recent|popular/ }
  get 'books/:author/:title/read(/:page)' => 'books#read', as: 'read_book'
  # legacy URL
  get 'books/:id/read(/:page)' => 'books#read_id', as: 'read_id_book', constraints: { id: /[a-f0-9]{24}/ }

  #resource :mandrill, :controller => 'mandrill', :only => [:show,:create]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
