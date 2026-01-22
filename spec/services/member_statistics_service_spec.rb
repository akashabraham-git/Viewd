require 'rails_helper'

RSpec.describe MemberStatisticsService do
  let(:member) { create(:member) }
  let(:movie1) { create(:movie, release_date: Date.new(2020, 1, 1), runtime: 120, language: 'en', origin_country: 'US') }
  let(:movie2) { create(:movie, release_date: Date.new(2021, 6, 15), runtime: 100, language: 'es', origin_country: 'ES') }

  describe '#call all time statistics' do
    before do
      create(:library_entry, member: member, movie: movie1, watched_date: Date.today)
      create(:library_entry, member: member, movie: movie2, watched_date: Date.today)
      create(:rating, member: member, movie: movie1, rating: 5)
      create(:rating, member: member, movie: movie2, rating: 4)
    end

    it 'returns all time statistics' do
      stats = MemberStatisticsService.new(member).call

      expect(stats[:total_films]).to eq(2)
      expect(stats[:average_rating]).to eq(4.5)
      expect(stats[:total_hours]).to be > 0
    end

    it 'calculates release year distribution' do
      stats = MemberStatisticsService.new(member).call

      expect(stats[:release_year_distribution][2020]).to eq(1)
      expect(stats[:release_year_distribution][2021]).to eq(1)
    end

    it 'includes reviewed films count' do
      create(:review, member: member, movie: movie1)
      stats = MemberStatisticsService.new(member).call

      expect(stats[:reviewed_films]).to eq(1)
    end

    it 'includes top actors and directors' do
      stats = MemberStatisticsService.new(member).call

      expect(stats[:top_actors]).to be_a(Hash)
      expect(stats[:top_directors]).to be_a(Hash)
    end
  end

  describe '#call by year statistics' do
    before do
      this_year = Date.today.year
      create(:library_entry, member: member, movie: movie1, watched_date: Date.new(this_year, 1, 15))
      create(:library_entry, member: member, movie: movie2, watched_date: Date.new(this_year - 1, 6, 15))
      create(:rating, member: member, movie: movie1, rating: 5)
    end

    it 'filters statistics by year' do
      stats = MemberStatisticsService.new(member, Date.today.year).call

      expect(stats[:total_films]).to eq(1)
      expect(stats[:year]).to eq(Date.today.year)
    end

    it 'calculates weekly watches' do
      stats = MemberStatisticsService.new(member, Date.today.year).call

      expect(stats[:weekly_watches]).not_to be_empty
    end

    it 'tracks first and last watch' do
      stats = MemberStatisticsService.new(member, Date.today.year).call

      expect(stats[:first_watch]).to be_present
      expect(stats[:last_watch]).to be_present
    end

    it 'includes rating spread' do
      stats = MemberStatisticsService.new(member, Date.today.year).call

      expect(stats[:rating_spread]).to be_a(Hash)
    end
  end

  describe 'data calculations' do
    before do
      create(:library_entry, member: member, movie: movie1, watched_date: Date.today)
      create(:library_entry, member: member, movie: movie2, watched_date: Date.today)
    end

    it 'calculates total hours correctly' do
      service = MemberStatisticsService.new(member)
      service.send(:fetch_watched_entries)
      hours = service.send(:calculate_total_hours)

      expected_hours = (120 + 100) / 60.0
      expect(hours).to eq(expected_hours)
    end

    it 'calculates country breakdown' do
      stats = MemberStatisticsService.new(member).call

      expect(stats[:country_breakdown]['US']).to eq(1)
      expect(stats[:country_breakdown]['ES']).to eq(1)
    end

    it 'calculates language breakdown' do
      stats = MemberStatisticsService.new(member).call

      expect(stats[:language_breakdown]['en']).to eq(1)
      expect(stats[:language_breakdown]['es']).to eq(1)
    end
  end
end
