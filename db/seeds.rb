require 'net/http'  
require 'json'      

API_KEY = "815836d66ad7d58fb932fe1ce2a45187"  

# --- CLEAN DATABASE ---
puts "Cleaning database..."
Credit.destroy_all
Cast.destroy_all
Movie.destroy_all
puts "Database cleared."

def fetch_from_tmdb(url)
  uri = URI(url)                      
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
  
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  JSON.parse(response.body)              
rescue => e                         
  puts "Error fetching data: #{e.message}"
  nil                                 
end

def create_movie(movie_data)
  details_url = "https://api.themoviedb.org/3/movie/#{movie_data['id']}?api_key=#{API_KEY}"
  details = fetch_from_tmdb(details_url)
  return nil unless details 
  
  movie = Movie.create!(
    tmdb_id: movie_data['id'],
    title: movie_data['title'],                    
    release_date: movie_data['release_date'],    
    poster_url: movie_data['poster_path'] ? "https://image.tmdb.org/t/p/w500#{movie_data['poster_path']}" : nil,
    language: movie_data['original_language'],
    runtime: details['runtime'],
    synopsis: movie_data['overview'] # Fixed the typo from your reference
  )
  movie
end

def create_cast_and_credits(movie, tmdb_movie_id)
  credits_url = "https://api.themoviedb.org/3/movie/#{tmdb_movie_id}/credits?api_key=#{API_KEY}"
  credits = fetch_from_tmdb(credits_url)
  
  return unless credits && credits['cast']
  
  # Taking top 10 cast members to avoid hitting rate limits too quickly
  credits['cast'].first(10).each do |cast_data|
    # To get the BIO, we must fetch from the Person detail endpoint
    person_url = "api.themoviedb.org{cast_data['id']}?api_key=#{API_KEY}"
    person_details = fetch_from_tmdb(person_url)
    
    cast = Cast.find_or_initialize_by(tmdb_id: cast_data['id'])
    cast.update(
      name: cast_data['name'],
      pic: cast_data['profile_path'] ? "https://image.tmdb.org/t/p/w500#{cast_data['profile_path']}" : nil,
      bio: person_details ? person_details['biography'] : "Bio not available"
    )
    
    Credit.create!(
      movie: movie, 
      cast: cast, 
      role: cast_data['character'] # Changed from department to actual character name
    )
  end
end

# --- MAIN EXECUTION ---
url = "https://api.themoviedb.org/3/movie/popular?api_key=#{API_KEY}&page=1"
data = fetch_from_tmdb(url)

if data && data['results']
  data['results'].first(20).each do |movie_data|
    puts "Seeding Movie: #{movie_data['title']}..."
    movie = create_movie(movie_data)
    if movie
      create_cast_and_credits(movie, movie_data['id'])
      sleep(0.2) # Rate limit protection for 2025 API standards
    end
  end
else
  puts "Failed to fetch movies"
end

puts "\nSeeding complete!"
puts "   - #{Movie.count} movies"     
puts "   - #{Cast.count} cast members"
puts "   - #{Credit.count} credits"
