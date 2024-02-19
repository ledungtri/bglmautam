Rails.application.routes.draw do
  root 'classrooms#index'
  get '/', to: 'classrooms#index'

  resources :students, except: [:edit]

  get '/teachers/custom_export', to: 'teachers#teachers_custom_export_view'
  post '/teachers/custom_export', to: 'teachers#teachers_custom_export'
  resources :teachers, except: [:edit]

  get '/search', to: 'application#search'

  get '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export_view'
  post '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export'
  resources :classrooms do
    get '/students_personal_details', to: 'classrooms#students_personal_details'
    get '/custom_export', to: 'classrooms#custom_export_view'
    post '/custom_export', to: 'classrooms#custom_export'
  end

  resources :guidances
  resources :enrollments
  resources :evaluations

  resources :users
  resources :sessions, only: [:create]
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'
end
