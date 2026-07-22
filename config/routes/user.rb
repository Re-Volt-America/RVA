RVA::Application.routes.draw do
  get '/admin', to: redirect('/admin/seasons/stats')
  get '/admin/users', to: 'users#members', as: :admin_users
  get '/admin/seasons/stats', to: 'seasons#admin_stats', as: :admin_season_stats

  get '/users', :to => redirect('/users/register')

  # Well known users with alternative nicknames get their own redirects
  get '/B', :to => redirect('/BGM')
  get '/b', :to => redirect('/BGM')

  get '/G', :to => redirect('/GFORCE')
  get '/g', :to => redirect('/GFORCE')

  get '/V', :to => redirect('/VENDETT5')
  get '/v', :to => redirect('/VENDETT5')

  get '/users/new', :to => 'users#new'
  post '/users/import', :to => 'users#import'
  put '/:username', :to => 'users#edit'

  put '/users/locale', :to => 'users#update_locale'

  get ':username', :to => 'users#show', :as => :user
end
