Rails.application.routes.draw do
  post "login", to: "authentication#login"
  get "empresa/dashboard", to: "empresas#dashboard"
  # config/routes.rb
  get "/usuario-logado", to: "users#show_current_user"
  resources :projetos, only: [:index, :show, :create, :update, :destroy]
  resources :empresas, only: [:index, :show, :create, :update, :destroy]
  resources :icts, only: [:index, :show, :create, :update, :destroy]
  resources :responsaveis, only: [:index, :show, :create, :update, :destroy]
  resources :interesses, only: [:index, :show, :create, :update, :destroy]
  resources :contratos, only: [:index, :show, :create, :update, :destroy]
end
