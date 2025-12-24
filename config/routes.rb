Rails.application.routes.draw do
  # --- 1. System Admin & Login ---
  devise_for :system_admins

  namespace :admin do
    resources :leads
    resources :quotes do
      member do
        patch :update_status 
      end
    end
    root to: "leads#index"
  end

  # --- 2. Public Side ---
  
  # Static Pages
  get 'services', to: 'pages#services'
  get 'about',    to: 'pages#about'
  get 'home',     to: 'pages#home'  # <--- Added this for explicit access

  # Redirect old/broken links back to the form
  get '/quotes', to: redirect('/quotes/new')

  # Quote Logic
  resources :quotes, only: [:new, :create, :show]

  # --- THE BIG CHANGE ---
  # Old: root "quotes#new"
  # New: This points to your new "Sales Homepage"
  root "pages#home" 

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end