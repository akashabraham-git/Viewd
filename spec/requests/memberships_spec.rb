require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  let!(:member_profile) { create(:member) } 
  let!(:membership) { create(:membership, member: member_profile) }
  
  let!(:pro_tier) { create(:membership_tier, :pro) }
  let!(:free_tier) { create(:membership_tier, :free) }

  before do
    allow(member_profile.user).to receive(:country).and_return(member_profile.country)
    sign_in_as(member_profile.user)
  end

  def sign_in_as(user_to_sign_in)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_to_sign_in)
  end

  describe "GET /index" do
    it "assigns tiers excluding the 'Free' tier" do
      get memberships_path
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(pro_tier.name)
      expect(response.body).not_to include("Free")
    end

    
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the membership and redirects to user profile" do
        patch membership_path(membership), params: { membership_tier_id: pro_tier.id }
        
        membership.reload
        expect(membership.membership_tier_id).to eq(pro_tier.id)
        expect(membership.status).to eq("active")
        expect(response).to redirect_to(user_path(member_profile.user))
      end
    end

    context "when the update fails" do
      it "redirects to index with an alert" do
        allow_any_instance_of(Membership).to receive(:update).and_return(false)
        
        patch membership_path(membership), params: { membership_tier_id: pro_tier.id }
        
        expect(response).to redirect_to(memberships_path)
        expect(flash[:alert]).to eq("Update failed.")
      end
    end
  end
end