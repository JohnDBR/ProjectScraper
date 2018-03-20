Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:index, :create, :update, :destroy]
  # get 'users/:id', to: 'users#show' #What the code up do...

  resources :sessions, only: :create
  delete 'sessions', to: 'sessions#destroy'

  post 'scraper/student_schedule', to: 'scraper#student_schedule'
  post 'scraper/conflict_matrix', to: 'scraper#conflict_matrix'

  resources :groups, only: [:create, :update, :destroy]
  get 'groups', to: 'groups#index'

  resources :members, only: [:create, :update, :destroy] 
  post 'group_members', to: 'members#index'

end
