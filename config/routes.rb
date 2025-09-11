Rails.application.routes.draw do
  root 'classrooms#index'
  get '/', to: 'classrooms#index'

  get '/search', to: 'application#search'

  resources :students, only: [:index, :show, :new, :create, :update, :destroy]

  get '/teachers/attendances', to: 'teachers#attendances'
  get '/teachers/custom_export', to: 'teachers#teachers_custom_export_form'
  post '/teachers/custom_export', to: 'teachers#teachers_custom_export'
  resources :teachers, only: [:index, :show, :new, :create, :update, :destroy]

  resources :people, only: [:index, :show, :new, :create, :update, :destroy] do
    post '/data_fields/:key', to: 'data_fields#update'
  end

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

  namespace :api do
    get '/resource_types/:key', to: 'resource_types#index'

    resources :classrooms, only: [:index, :show] do
      get '/students', to: 'classrooms#students'
      get '/teachers', to: 'classrooms#teachers'
    end
    resources :people, only: [:index, :show]



    # Create Get List Update Delete

    # contact_resources = [:phones, :emails, :addresses]
    #
    # resources :resource_types, only: [:index], param: :key # TODO: Simplified Resource Types. Expose :index and :update
    resources :data_schemas, only: [:index, :show, :create, :update, :destroy]
    # # Grade Schemas
    #
    # resources :classrooms, only: [:index, :show, :create, :update, :destroy] do
    #   resources :guidances, only: [:index, :create]
    #   resources :enrollments, only: [:index, :create]
    # end
    #
    # resources :guidances, only: [:index, :show, :update, :destroy] do
    #   resources :attendances, only: [:index, :create]
    # end
    #
    # resources :enrollments, only: [:index, :show, :update, :destroy] do
    #   resources :attendances, only: [:index, :create]
    #   resources :evaluations, only: [:index, :create]
    #   resources :grades, only: [:index, :create]
    # end
    #
    # resources :attendances, only: [:show, :update, :destroy]
    # resources :evaluations, only: [:show, :update, :destroy]
    # resources :grades, only: [:show, :update, :destroy]
    #
    # resources :people, only: [:index, :show, :create, :update, :destroy] do
    #   resources :users, only: [:index, :create]
    #   contact_resources.each { |r| resources r, only: [:index, :create] }
    # end
    # resources :users, only: [:show, :update, :destroy]
    # contact_resources.each { |r| resources r, only: [:show, :update, :destroy] }
  end
end
