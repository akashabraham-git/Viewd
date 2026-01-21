require 'rails_helper'

RSpec.describe "Api::V1::Casts", type: :request do
  let!(:cast_member) { create(:cast, name: "Tom Hanks") }
  let(:moderator) { create(:moderator).user }
  let(:member) { create(:member).user }
  let(:valid_params) { { cast: { name: "Meryl Streep", bio: "Legendary actress" } } }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns list of cast members" do
      get api_v1_casts_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "returns specific cast member" do
      get api_v1_cast_path(cast_member)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tom Hanks")
    end

    it "returns 404 for missing cast" do
      get api_v1_cast_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    it "allows moderator to create cast" do
      sign_in_as(moderator)
      expect { post api_v1_casts_path, params: valid_params }.to change(Cast, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "denies member from creating" do
      sign_in_as(member)
      post api_v1_casts_path, params: valid_params
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 when creation fails" do
      sign_in_as(moderator)
      post api_v1_casts_path, params: { cast: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /update" do
    it "updates cast details" do
      sign_in_as(moderator)
      patch api_v1_cast_path(cast_member), params: { cast: { name: "Updated Name" } }
      expect(cast_member.reload.name).to eq("Updated Name")
      expect(response).to have_http_status(:ok)
    end

    it "returns 422 when update fails" do
      sign_in_as(moderator)
      patch api_v1_cast_path(cast_member), params: { cast: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    it "removes cast member" do
      sign_in_as(moderator)
      expect { delete api_v1_cast_path(cast_member) }.to change(Cast, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end