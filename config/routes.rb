Rails.application.routes.draw do
  root 'classrooms#index'
  get '/', to: 'classrooms#index'

  resources :students
  resources :teachers

  get '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export_view'
  post '/classrooms/custom_export', to: 'classrooms#classrooms_custom_export'

  resources :classrooms do
    get '/students_personal_details', to: 'classrooms#students_personal_details'
    get '/custom_export', to: 'classrooms#custom_export_view'
    post '/custom_export', to: 'classrooms#custom_export'
  end

  resources :guidances
  resources :enrollments

  resources :users
  resources :sessions, only: [:create]
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'

  get '/search', to: 'application#search'

  get '/admin', to: 'application#admin'

  # TODO: Move to rake tasks
  # get '/migration/set_end_of_year_result', to: 'migration#set_end_of_year_result'
  # get '/migration/create_new_cells', to: 'migration#create_new_cells'
  # get '/migration/assign_new_cells', to: 'migration#assign_new_cells'
end
