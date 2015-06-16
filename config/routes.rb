Rails.application.routes.draw do
  get 'feed' => 'feeds#getrss'
  resources :feeds
end
