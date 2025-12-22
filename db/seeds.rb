require 'net/http'  
require 'json'      

API_KEY = "815836d66ad7d58fb932fe1ce2a45187"  

puts "Cleaning database..."
Credit.destroy_all
Cast.destroy_all
Genre.destroy_all
Movie.destroy_all
puts "Database cleared."

def fetch_from_tmdb(url, retries = 3)
  uri = URI(url)                      
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
  http.open_timeout = 15 
  http.read_timeout = 15 
  
  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    
    if response.code == "200"
      JSON.parse(response.body)
    elsif response.code == "429" 
      puts "Rate limit hit. Sleeping..."
      sleep(5)
      fetch_from_tmdb(url, retries - 1) if retries > 0
    else
      puts "TMDB Error: #{response.code} for #{url}"
      nil
    end
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    if retries > 0
      puts "Timeout for #{uri.host}. Retrying (#{retries} left)..."
      sleep(2)
      fetch_from_tmdb(url, retries - 1)
    else
      puts "Final timeout failure for #{url}"
      nil
    end
  rescue => e                         
    puts "Error: #{e.message}"
    nil                                 
  end
end

def create_movie(movie_data)
  details_url = "https://api.themoviedb.org/3/movie/#{movie_data['id']}?api_key=#{API_KEY}"
  details = fetch_from_tmdb(details_url)
  return nil unless details 
  
  lang_name = details['spoken_languages']&.first ? details['spoken_languages'][0]['english_name'] : movie_data['original_language']
  country_name = details['production_countries']&.first ? details['production_countries'][0]['name'] : "Unknown"

  movie = Movie.create!(
    tmdb_id: movie_data['id'],
    title: movie_data['title'],                    
    release_date: movie_data['release_date'],    
    poster_url: movie_data['poster_path'] ? "https://image.tmdb.org/t/p/w500#{movie_data['poster_path']}" : nil,
    language: lang_name,
    origin_country: country_name,
    status: details['status'],
    runtime: details['runtime'],
    synopsis: movie_data['overview']
  )

  details['genres']&.each do |genre_data|
    genre = Genre.find_or_create_by(name: genre_data['name'])
    movie.genres << genre
  end

  movie
end

def process_person(movie, person_data, is_cast)
  person_url = "https://api.themoviedb.org/3/person/#{person_data['id']}?api_key=#{API_KEY}"
  details = fetch_from_tmdb(person_url)
  
  person = Cast.find_or_initialize_by(tmdb_id: person_data['id'])
  person.update!(
    name: person_data['name'],
    pic: person_data['profile_path'] ? "https://image.tmdb.org/t/p/w500#{person_data['profile_path']}" : nil,
    bio: details ? details['biography'] : "Bio not available"
  )

  Credit.create!(
    movie: movie,
    cast: person,
    character: is_cast ? person_data['character'] : nil,
    job: is_cast ? "Actor" : person_data['job']
  )
end

def create_credits(movie, tmdb_id)
  url = "https://api.themoviedb.org/3/movie/#{tmdb_id}/credits?api_key=#{API_KEY}"
  credits = fetch_from_tmdb(url)
  return unless credits

  credits['cast']&.first(9)&.each { |data| process_person(movie, data, true) }
  credits['crew']&.first(10)&.each { |data| process_person(movie, data, false) }
end

url = "https://api.themoviedb.org/3/movie/popular?api_key=#{API_KEY}&page=1"
data = fetch_from_tmdb(url)

if data && data['results']
  data['results'].first(20).each do |movie_data|
    puts "Seeding: #{movie_data['title']}..."
    movie = create_movie(movie_data)
    if movie
      create_credits(movie, movie_data['id'])
      sleep(1.0)
    end
  end
end

puts "\nSeeding complete!"
puts "Movies: #{Movie.count} | Cast: #{Cast.count} | Credits: #{Credit.count} | Genres: #{Genre.count}"




puts "Cleaning membership tiers..."
Membership.destroy_all
MembershipTier.destroy_all


# Define base prices in USD
# We change names to match your Pro/Patron idea
base_prices = {
  pro: 10,
  patron: 20
}

country_multipliers = {
  "usa" => 1, "india" => 80, "uk" => 0.8, "canada" => 1.3,
  "australia" => 1.5, "germany" => 0.9, "france" => 0.9,
  "japan" => 140, "brazil" => 5, "unknown" => 1
}

puts "Populating Membership Tiers..."

MembershipTier.countries.keys.each do |country_name|
  multiplier = country_multipliers[country_name] || 1

  # PRO Tier -> Gold Badge
  MembershipTier.create!(
    name: "Pro",
    price: (base_prices[:pro] * multiplier).round,
    country: country_name,
    badge: :gold,
    has_ads: false,
    can_view_stats: true
  )

  # PATRON Tier -> Diamond Badge
  MembershipTier.create!(
    name: "Patron",
    price: (base_prices[:patron] * multiplier).round,
    country: country_name,
    badge: :diamond,
    has_ads: false,
    can_view_stats: true
  )
end

# FREE Tier -> No Badge (nil)
# Note: We create one Free tier per country or one global one
MembershipTier.create!(
  name: "Free",
  price: 0,
  country: :unknown,
  badge: nil, 
  has_ads: true,
  can_view_stats: false
)

puts "Seeds created: #{MembershipTier.pluck(:name, :badge, :country).inspect}"