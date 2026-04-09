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

  def self.find_in_tmdb(search_params)
    api_key = ENV['TMDB_API_KEY']

    title = search_params[:title]
    release_year = search_params[:release_year]
    language = search_params[:language]

    query = CGI.escape(title.to_s)
    url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{query}"

    response = Faraday.get(url)
    data = JSON.parse(response.body)
    results = data['results'] || []

    if language == 'en'
      results = results.select { |movie| movie['original_language'] == 'en' }
    end

    if release_year.present?
      results = results.select do |movie|
        movie['release_date'].present? &&
          movie['release_date'].start_with?(release_year)
      end
    end

    results
  end
end