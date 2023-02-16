RVA::Application.routes.draw do
  get ":name", :to => "users#show", :as => :user
end
