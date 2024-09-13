Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :chatrooms, only: [:create, :index] do
    resources :messages, only: [:create]
  end

  get '/search', to: 'search#search'
end
