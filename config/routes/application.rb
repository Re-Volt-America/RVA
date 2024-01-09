RVA::Application.routes.draw do
  default_url_options :host => 'localhost'

  root :to => 'application#index', :via => 'get'

  get 'about' => 'application#about'
  get 'rules' => 'rules#index'
  get 'terms' => 'rules#terms'
  get 'privacy' => 'rules#privacy'
  get 'logos' => 'assets#index'
  get 'play' => 'play#index'
  get 'downloads' => 'downloads#index'
  get 'staff' => 'staff#index'
  get 'points' => 'points#index'
  get 'stats' => 'stats#index'
  get 'faq' => 'faq#index'

  resources :repositories

  resources :seasons
  resources :rankings
  resources :tracks do
    collection do
      post :import
    end
  end

  # NOTE: Maybe not the best way of adding routing exceptions?
  get '/cars/rookie' => 'cars#rookie'
  get '/cars/amateur' => 'cars#amateur'
  get '/cars/advanced' => 'cars#advanced'
  get '/cars/semipro' => 'cars#semipro'
  get '/cars/pro' => 'cars#pro'
  get '/cars/superpro' => 'cars#superpro'
  get '/cars/clockwork' => 'cars#clockwork'

  resources :cars do
    collection do
      post :import
    end
  end

  resources :tournaments
  resources :teams do
    collection do
      put :add_member, :to => "teams#add_member"
    end
  end

  resources :sessions do
    collection do
      get :rankings
      post :import
    end
  end

  match '404', :to => 'errors#not_found', :via => :all
  match '422', :to => 'errors#illegal', :via => :all
  match '500', :to => 'errors#internal_error', :via => :all

  devise_for :users,
             :controllers => {
               :confirmations => 'users/confirmations',
               :registrations => 'users/registrations'
             },
             :path_names => {
               :sign_in => 'login',
               :sign_out => 'logout',
               :sign_up => 'register',
               :password => 'forgot',
               :confirmation => 'confirm'
             }

  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    post '/login' => 'devise/sessions#create'
    delete '/logout' => 'devise/sessions#destroy'

    post '/forgot' => 'devise/passwords#create'
    get '/forgot' => 'devise/passwords#new'
    get '/forgot/:reset_password_token' => 'devise/passwords#edit'
    put '/forgot' => 'devise/passwords#update'

    post '/register' => 'registrations#create'
    get '/register' => 'registrations#new'
    get '/account' => 'registrations#edit'
    put '/account' => 'registrations#update'

    post '/confirm' => 'confirmations#create'
    get '/confirm' => 'confirmations#new'
    get '/confirm/:confirmation_token' => 'confirmations#show', :as => :confirmify
    put '/confirm' => 'confirmations#confirm_account', :as => :finalize_confirmation
  end
end
