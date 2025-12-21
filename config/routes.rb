Rails.application.routes.draw do
  devise_for :system_admins
  # --- Admin Panel ---
  namespace :admin do
    resources :leads
    
    # Updated resources for Quotes to handle Status and Excel
    resources :quotes do
      member do
        # Allows you to click a button to change status (Pending/Paid/Lost)
        patch :update_status 
      end
    end
    
    root to: "leads#index"
  end

  # --- Public Side ---
  resources :quotes, only: [:new, :create, :show]

  root "quotes#new"

  get "up" => "rails/health#show", as: :rails_health_check
end