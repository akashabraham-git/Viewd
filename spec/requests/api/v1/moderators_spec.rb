require 'rails_helper'

RSpec.describe "Api::V1::Moderators", type: :request do
  let!(:mod_record) { create(:moderator, department: "Content") }
  let(:mod_user) { mod_record.user }
  let(:member_user) { create(:member).user }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "Authorization" do
    it "denies access to members" do
      sign_in_as(member_user)
      get "/api/v1/moderators/#{mod_record.id}"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /show" do
    before { sign_in_as(mod_user) }

    it "returns moderator details" do
      get "/api/v1/moderators/#{mod_record.id}"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for missing moderator" do
      get "/api/v1/moderators/0"
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Moderator not found")
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(mod_user) }

    context "with valid params" do
      it "updates the department and user info" do
        patch "/api/v1/moderators/#{mod_record.id}", params: { 
          moderator: { department: "Legal", user_attributes: { id: mod_user.id, name: "New Name" } } 
        }
        expect(response).to have_http_status(:ok)
        expect(mod_record.reload.department).to eq("Legal")
        expect(mod_user.reload.name).to eq("New Name")
      end
    end

    context "with invalid params " do
      it "returns 422 when update fails" do
        patch "/api/v1/moderators/#{mod_record.id}", params: { 
          moderator: { user_attributes: { id: mod_user.id, username: "" } } 
        }
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end
  end

  describe "DELETE /destroy" do
    before { sign_in_as(mod_user) }

    it "removes the moderator account" do
      expect {
        delete "/api/v1/moderators/#{mod_record.id}"
      }.to change(Moderator, :count).by(-1)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Moderator account removed")
    end
  end
end