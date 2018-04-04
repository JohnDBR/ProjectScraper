Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:index, :show, :create, :update, :destroy]
  # get 'users/:id', to: 'users#show' #What the code up do...
  get 'schedule', to: 'users#schedule'

  resources :sessions, only: :create
  delete 'sessions', to: 'sessions#destroy'
  post 'sessions/:link', to: 'sessions#guest_create'

  post 'scraper/student_schedule', to: 'scraper#student_schedule'
  post 'scraper/conflict_matrix', to: 'scraper#conflict_matrix'

  resources :groups, only: [:index, :show, :create, :update, :destroy]
  # get 'groups', to: 'groups#index'

  resources :groups do
    resources :members, only: [:show, :index, :create, :update, :destroy]
    # get ':group_id/members/:id', to: 'members#show'
  end
  post 'groups/:id/add_schedules', to: 'groups#add_schedules'
  get 'groups/:id/schedule', to: 'groups#schedule'

  resources :groups do
    resources :links, only: [:create]
  end
  post 'groups/links/:link', to: 'links#open'
  post 'groups/links/add_schedules/:link', to: 'links#add_schedules'
  get 'groups/links/schedule/:link', to: 'links#schedule'
  delete 'groups/links/:link', to: 'links#destroy'

end
