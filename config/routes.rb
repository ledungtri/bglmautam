Rails.application.routes.draw do
  root 'cells#index'
  get '/', to: 'cells#index'

  resources :students
  resources :teachers

  get 'cells/all', to: 'cells#all'
  resources :cells do 
    get '/students_personal_details', to: 'cells#students_personal_details'
  end

  resources :instructions
  resources :attendances

  resources :users
  resources :sessions, only: [:create]
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'

  get '/search', to: 'application#search'

  get '/admin', to: 'application#admin'
end
