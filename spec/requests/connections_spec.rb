require 'rails_helper'

RSpec.describe "Connections", type: :request do
  let!(:member_me) { create(:member) }
  let!(:member_target) { create(:member) }
  let(:me) { member_me.user }
  let(:target) { member_target.user }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(me)
    
    allow_any_instance_of(ConnectionsController).to receive(:set_me).and_wrap_original do |method|
      @me = me
      method.call
    end
  end

  describe "GET /index" do
    context "with valid types" do
      it "assigns following users" do
        get "/users/#{target.id}/connections", params: { type: 'following' }
        expect(response).to have_http_status(:ok)
      end

      it "assigns followers" do
        get "/users/#{target.id}/connections", params: { type: 'followers' }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid type" do
      it "redirects to user path" do
        get "/users/#{target.id}/connections", params: { type: 'invalid' }
        expect(response).to redirect_to(user_path(target))
        expect(flash[:alert]).to eq("Invalid operation")
      end
    end
  end

  describe "POST /create" do
    it "creates a connection" do
      expect {
        post "/connections", params: { following_id: target.id }
      }.to change(Connection, :count).by(1)
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /destroy" do
    context "when connection exists" do
      before do
        create(:connection, follower: member_me, following: member_target)
      end

      it "destroys the connection" do
        expect {
          delete "/connections/#{target.id}"
        }.to change(Connection, :count).by(-1)
        expect(flash[:notice]).to eq("Unfollowed successfully.")
      end
    end

    context "when connection does not exist" do
      it "sets alert flash" do
        delete "/connections/#{target.id}"
        expect(flash[:alert]).to eq("Could not find connection to remove.")
      end
    end
  end
end