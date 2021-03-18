Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :clients, only: %i[index create update]
      get '/clients/:id/sales', to: 'clients#sales', as: 'client_sales'

      resources :products, only: %i[index create update]

      resources :sales, only: %i[index create update]
      get '/sales/:id/payments', to: 'sales#payments', as: 'sale_payments'

      resources :payment_histories, only: %i[create update destroy]

      post '/sign_up', to: 'users#sign_up', as: 'user_sign_up'
      get '/sign_in', to: 'users#sign_in', as: 'user_sign_in'
    end
  end
end
