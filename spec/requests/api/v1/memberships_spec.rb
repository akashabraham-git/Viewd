require 'rails_helper'

RSpec.describe "Api::V1::Memberships", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:tier) { create(:membership_tier, :pro) }
  let!(:membership) { create(:membership, member: member_record) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns available membership tiers for user's country" do
      sign_in_as(user)
      get "/api/v1/memberships"
      expect(response).to have_http_status(:ok)
    end

    it "defaults to unknown country if user country is nil" do
      member_record.update(country: nil)
      sign_in_as(user)
      get "/api/v1/memberships"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "returns the current user's membership" do
      sign_in_as(user)
      get "/api/v1/memberships/show" 
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(user) }

    it "successfully upgrades membership to a new tier" do
      put "/api/v1/memberships/#{membership.id}", params: { membership_tier_id: tier.id }
      
      expect(response).to have_http_status(:ok)
      membership.reload
      expect(membership.membership_tier_id).to eq(tier.id)
      expect(membership.status).to eq("active")
    end

    it "returns 404 when tier id is invalid" do
      put "/api/v1/memberships/#{membership.id}", params: { membership_tier_id: 0 }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 if update fails" do
      allow_any_instance_of(Membership).to receive(:update).and_return(false)
      errors_stub = double('errors', full_messages: ["Payment failed"])
      allow_any_instance_of(Membership).to receive(:errors).and_return(errors_stub)

      patch "/api/v1/memberships/#{membership.id}", params: { membership_tier_id: tier.id }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "Authorization" do
    it "returns 403 for non-member users (Moderators)" do
      mod_user = create(:moderator).user
      sign_in_as(mod_user)
      get "/api/v1/memberships"
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("Only members can manage memberships")
    end
  end
end