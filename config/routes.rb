Rails.application.routes.draw do
  root 'classrooms#index'
  get '/', to: 'classrooms#index'

  get '/search', to: 'application#search'

  resources :students, except: [:edit]

  get '/teachers/custom_export', to: 'teachers#teachers_custom_export_form'
  post '/teachers/custom_export', to: 'teachers#teachers_custom_export'
  resources :teachers, except: [:edit]

  get '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export_form'
  post '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export'
  resources :classrooms, except: [:edit] do
    get '/students_personal_details', to: 'classrooms#students_personal_details'
    get '/custom_export', to: 'classrooms#custom_export_form'
    post '/custom_export', to: 'classrooms#custom_export'
  end

  resources :guidances, only: [:show, :create, :update, :destroy]
  resources :enrollments, only: [:show, :create, :update, :destroy]
  resources :evaluations, only: [:create, :update, :destroy]

  resources :users, only: [:create, :update, :destroy]
  resources :sessions, only: [:create]
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'
end
