class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_terms, release_year = nil, language = nil)
    response = Faraday.get('https://api.themoviedb.org/3/search/movie') do |req|
      req.params['api_key'] = ENV['TMDB_API_KEY']
      req.params['query'] = search_terms
      req.params['year'] = release_year unless release_year.blank?
      req.params['language'] = language unless language.blank?
    end

    parsed = JSON.parse(response.body)
    results = parsed['results'] || []

    results.map do |movie_data|
      Movie.new(
        title: movie_data['title'],
        rating: 'R',
        description: movie_data['overview'],
        release_date: movie_data['release_date']
      )
    end.reject do |movie|
      Movie.exists?(title: movie.title, release_date: movie.release_date)
    end
  end

end
