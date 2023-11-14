RVA::Application.routes.draw do
  get '/users', :to => redirect('/users/register')

  get '/users/new', :to => 'users#new'
  post '/users/import', :to => 'users#import'

  get ':username', :to => 'users#show', :as => :user
end
