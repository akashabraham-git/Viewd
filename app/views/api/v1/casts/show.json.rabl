object @cast_member => :cast

attributes :id, :name, :pic, :bio

node(:jobs) { @jobs || []}

node(:movies) do
  @movies.map { |m| { id: m.id, title: m.title, poster_url: m.poster_url, release_date: m.release_date } }
end

node(:credits_by_job) do
  @grouped_credits.map do |job, credits|
    {
      job: job,
      credits: credits.map do |credit|
        {
          id: credit.id,
          character: credit.character,
          movie: {
            id: credit.movie.id,
            title: credit.movie.title,
            poster_url: credit.movie.poster_url
          }
        }
      end
    }
  end
end