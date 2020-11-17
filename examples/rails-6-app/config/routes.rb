Rails.application.routes.draw do
  get 'auth/:provider/callback' => 'authorizations#create'
  resources :teams, only: [:index]
  root 'welcome#index'
end
