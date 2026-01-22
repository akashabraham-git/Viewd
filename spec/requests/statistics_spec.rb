require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
  let(:user) { create(:user, actable: create(:member)) }
  let(:member) { user.actable }
  let(:pro_tier) { create(:membership_tier, name: 'Pro') }

  before do
    create(:membership, member: member, membership_tier: pro_tier, status: :active)
  end

  describe 'GET #index' do
    context 'when user is authenticated and has pro membership' do
      before { sign_in user }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns all_time_stats' do
        get :index
        expect(assigns(:all_time_stats)).to be_a(Hash)
      end

      it 'assigns available_years' do
        get :index
        expect(assigns(:available_years)).to be_an(Array)
      end
    end

    context 'when user does not have pro membership' do
      let(:free_tier) { create(:membership_tier, name: 'Free') }

      before do
        member.membership.update(membership_tier: free_tier)
        sign_in user
      end

      it 'redirects to memberships page' do
        get :index
        expect(response).to redirect_to(memberships_path)
      end

      it 'shows alert message' do
        get :index
        expect(flash[:alert]).to include('Upgrade to Pro or Patron')
      end
    end

    context 'when user is not a member' do
      let(:moderator) { create(:moderator) }
      let(:non_member_user) { moderator.user }

      before { sign_in non_member_user }

      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'shows alert message' do
        get :index
        expect(flash[:alert]).to include('Statistics are only available for members')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #by_year' do
    let(:movie) { create(:movie, release_date: Date.new(2023, 1, 1)) }

    before do
      this_year = Date.today.year
      create(:library_entry, member: member, movie: movie, watched_date: Date.new(this_year, 6, 15))
      sign_in user
    end

    context 'with valid year' do
      it 'returns http success' do
        current_year = Date.today.year
        get :by_year, params: { year: current_year }
        expect(response).to have_http_status(:success)
      end

      it 'assigns year_stats' do
        current_year = Date.today.year
        get :by_year, params: { year: current_year }
        expect(assigns(:year_stats)).to be_a(Hash)
      end

      it 'filters stats by year' do
        current_year = Date.today.year
        get :by_year, params: { year: current_year }
        expect(assigns(:year_stats)[:year]).to eq(current_year)
      end
    end

    context 'with invalid year' do
      it 'redirects with invalid year' do
        get :by_year, params: { year: 1999 }
        expect(response).to redirect_to(statistics_path)
      end

      it 'redirects with future year' do
        future_year = Date.today.year + 1
        get :by_year, params: { year: future_year }
        expect(response).to redirect_to(statistics_path)
      end
    end
  end
end
