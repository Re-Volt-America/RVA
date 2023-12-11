RVA::Application.routes.draw do
  get '/users', :to => redirect('/users/register')

  # Well known alternative nicknames get their own redirects
  get '/B', :to => redirect('/BGM')
  get '/G', :to => redirect('/GFORCE')
  get '/V', :to => redirect('/VENDETT5')

  get '/users/new', :to => 'users#new'
  post '/users/import', :to => 'users#import'
  put '/:username', :to => 'users#edit'

  get ':username', :to => 'users#show', :as => :user
end
