Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  scope 'api/v1/expense_tracker/' do
    scope 'user' do
      post 'onboard', to: 'users#create'
      post 'signup', to: 'users#signup'
      post 'login', to: 'sessions#create'
      post 'logout', to: 'sessions#destroy'
    end
    resources :users, only: %i[] do
      resources :expenses, only: %i[index show create update] do
        post 'comments', to: 'comments#add_expense_comment'
        get 'comments', to: 'comments#index_expense_comments'
      end
      resources :reports, only: %i[show create update] do
        post 'comments', to: 'comments#add_report_comment'
        get 'comments', to: 'comments#index_report_comments'
      end
    end
  end
end
