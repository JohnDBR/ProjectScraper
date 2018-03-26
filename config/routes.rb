Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:index, :create, :update, :destroy]
  # get 'users/:id', to: 'users#show' #What the code up do...

  resources :sessions, only: :create
  delete 'sessions', to: 'sessions#destroy'
  post 'sessions/:link', to: 'sessions#guest_create'

  post 'scraper/student_schedule', to: 'scraper#student_schedule'
  post 'scraper/conflict_matrix', to: 'scraper#conflict_matrix'

  resources :groups, only: [:index, :create, :update, :destroy]
  # get 'groups', to: 'groups#index'
  get 'groups/:id/link', to: 'groups#create_link'
  post 'groups/:link', to: 'groups#open_link'
  delete 'groups/:link', to: 'groups#delete_link'

  resources :groups do
    resources :members, only: [:show, :index, :create, :update, :destroy]
    # get ':group_id/members/:id', to: 'members#show'
  end

end
