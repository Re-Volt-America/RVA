RVA::Application.routes.draw do
  get '/users', to: redirect('/users/register')

  get ':username', :to => 'users#show', :as => :user
end
