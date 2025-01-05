Rails.application.routes.draw do
  root 'classrooms#index'
  get '/', to: 'classrooms#index'

  get '/search', to: 'application#search'

  resources :students, only: [:index, :show, :new, :create, :update, :destroy]

  get '/teachers/attendances', to: 'teachers#attendances'
  get '/teachers/custom_export', to: 'teachers#teachers_custom_export_form'
  post '/teachers/custom_export', to: 'teachers#teachers_custom_export'
  resources :teachers, only: [:index, :show, :new, :create, :update, :destroy]

  get '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export_form'
  post '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export'
  resources :classrooms, only: [:index, :show, :new, :create, :update, :destroy] do
    get '/students_personal_details', to: 'classrooms#students_personal_details'
    get '/attendances', to: 'classrooms#attendances'
    get '/evaluation', to: 'classrooms#evaluation'
    get '/custom_export', to: 'classrooms#custom_export_form'
    post '/custom_export', to: 'classrooms#custom_export'
  end

  secondary_resources = [
    :guidances,
    :enrollments,
    :evaluations,
    :grades,
    :users,
    :attendances,
    :phones,
    :emails,
    :addresses
  ]
  secondary_resources.each do |resource|
    resources resource, only: [:create, :update, :destroy]
  end

  resources :sessions, only: [:create]
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'
end
