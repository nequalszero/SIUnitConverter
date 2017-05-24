Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :units, defaults: {format: :json} do
    resources :si, only: [:index]
  end

  root "static_pages#root"
end
