Rails.application.routes.draw do
  post "login", to: "authentication#login"
  resources :projetos, only: [:index, :show, :create, :update, :destroy]
  resources :empresas, only: [:index, :show, :create, :update, :destroy]
  resources :icts, only: [:index, :show, :create, :update, :destroy]
  resources :responsaveis, only: [:index, :show, :create, :update, :destroy]
  resources :interesses, only: [:index, :show, :create, :update, :destroy]
end
