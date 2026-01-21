require 'rails_helper'

RSpec.describe "Api::V1::Connections", type: :request do
  let!(:member_me) { create(:member) }
  let!(:member_target) { create(:member) }
  let(:me) { member_me.user }
  let(:target) { member_target.user }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    context "with valid type" do
      it "returns following list" do
        get api_v1_user_connections_path(target), params: { type: 'following' }
        expect(response).to have_http_status(:ok)
      end

      it "returns followers list" do
        get api_v1_user_connections_path(target), params: { type: 'followers' }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "returns 404 for missing user" do
        get api_v1_user_connections_path(0), params: {  type: 'following' }
        expect(response).to have_http_status(:not_found)
      end

      it "returns 400 for invalid type" do
        get api_v1_user_connections_path(target), params: {type: 'invalid' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "POST /create" do
    before { sign_in_as(me) }

    it "follows a user successfully" do
      expect {
        post api_v1_connections_path, params: { following_id: target.id }
      }.to change(Connection, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns 404 for non-existent target" do
      post api_v1_connections_path, params: { following_id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /destroy" do
    before { sign_in_as(me) }

    context "when connection exists" do
      before { create(:connection, follower: member_me, following: member_target) }

      it "unfollows successfully" do
        expect {
          delete api_v1_connection_path(target.id)
        }.to change(Connection, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when connection does not exist" do
      it "returns 404" do
        delete api_v1_connection_path(target.id)
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for invalid user id" do
        delete api_v1_connection_path(0)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end