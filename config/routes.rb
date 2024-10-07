Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  mount ActionCable.server => '/cable'
  resources :chatrooms, only: [:create, :index] do
    resources :messages, only: [:create, :index]
  end

  get '/search', to: 'search#search'
  get '/current_user', to: 'current_user#current_user'
end
