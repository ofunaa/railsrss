Rails.application.routes.draw do
	root :to => "feeds#index"
  	get 'feed' => 'feeds#getrss'
  	resources :feeds
end
