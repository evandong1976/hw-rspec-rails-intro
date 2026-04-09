Rottenpotatoes::Application.routes.draw do
  resources :movies
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')

  get '/search', to: 'movies#search_tmdb', as: 'search_tmdb'
end
