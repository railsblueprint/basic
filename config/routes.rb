Rails.application.routes.draw do
  devise_for :users,
             path_names: {:sign_in => 'login', :sign_out => 'logout', :sign_up => 'register'}

  root 'static_pages#home'

  get '/faq', to: 'static_pages#faq', as: :faq

  draw(:admin)

  resources :posts, path: :blog
  resources :users, only: [:show]

  get "/profile", to: "users#show", as: :profile
  get "/profile/edit", to: "users#edit", as: :edit_profile
  patch "/profile/edit", to: "users#update"
  post "/profile/password", to: "users#password", as: :update_password
  post "/profile/disavow",  to: "users#disavow", as: :disavow
  post "/profile/cancel_email_change", to: "users#cancel_email_change", as: :cancel_email_change
  post "/profile/resend_confirmation_email", to: "users#resend_confirmation_email", as: :resend_confirmation_email

  get "/contacts", to: "contacts#new"
  post "/contacts", to: "contacts#create"


  %w(404 422 500).each do |code|
    get code, to: 'errors#show', code: code
  end

  get "/*path", to: 'static_pages#page'

end
