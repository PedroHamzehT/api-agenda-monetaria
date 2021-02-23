Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :clients, only: %i[index create update]
      get '/clients/:id/sales', to: 'clients#sales', as: 'client_sales'
    end
  end
end
