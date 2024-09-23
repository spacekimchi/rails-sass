Rails.application.routes.draw do
  # Defines the root path route ("/")
  root 'home#index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Clearance routes start
  resources :passwords, controller: "passwords", only: [:create, :new]
  resource :session, controller: "sessions", only: [:create]

  resources :users, controller: "users", only: [:create] do
    resources :purchased_products
    resource :password, controller: "passwords", only: [:edit, :update]
  end

  get "/sign_in" => "sessions#new", as: "sign_in"
  delete "/sign_out" => "sessions#destroy", as: "sign_out"
  get "/sign_up" => "users#new", as: "sign_up"

  resources :verification, only: [:edit], param: :verification_token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # An example of using clearance to put route guarding in the routes level
  # These routes will not even be defined for users without super_admin role
  constraints Clearance::Constraints::SignedIn.new { |user| user.super_admin? } do
    namespace :admin do
      root 'dashboard#show'

      resources :products do
        resources :product_prices
      end

      resources :users do
        member do
          post :toggle_admin
          post :toggle_super_admin
          post :send_verification_email
        end
      end

      resources :support_tickets, only: %i[index] do
        member do
          post :assign_to_user
        end
      end

      resources :application_errors, only: %i[index]

      namespace :stripe do
        get 'products', to: 'products#index'
        get 'product/:id', to: 'products#show'
        post 'products', to: 'products#create'
        put 'products', to: 'products#update'
        get 'prices', to: 'prices#index'
        post 'prices', to: 'prices#create'
        put 'prices', to: 'prices#update'
      end
    end
  end

  # constraints Clearance::Constraints::SignedOut.new do
  #   root to: "marketing#index"
  # end
  # Clearance routes end

  constraints Clearance::Constraints::SignedIn.new do
    namespace :stripe do
      post 'billing_portal_sessions', to: 'billing_portal_sessions#create'
    end
  end
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For Stripe webhooks
  namespace :stripe do
    post 'webhooks', to: 'webhooks#create'
  end

  resource :checkout, only: %i[new show]
  resources :products, only: %i[index show]

  resource :support_tickets, only: %i[new create]
end
