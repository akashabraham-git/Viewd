require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(Api::V1::BaseController) do
    skip_before_action :doorkeeper_authorize!
    
    before_action :authenticate_user_from_session!, only: [:protected_action]
    before_action :authorize_moderator!, only: [:moderator_only]

    def protected_action; render_success("Auth OK"); end
    def moderator_only; render_success("Mod OK"); end
    def test_error; render_error("Fail", :bad_request); end
  end

  before do
    routes.draw do
      get 'protected_action' => 'api/v1/base#protected_action'
      get 'moderator_only' => 'api/v1/base#moderator_only'
      get 'test_error' => 'api/v1/base#test_error'
    end
    allow(controller).to receive(:doorkeeper_authorize!).and_return(true)
  end

  let(:user) { create(:user, :as_member) }
  let(:moderator_user) { create(:user, :as_moderator) }

  describe "Methods Coverage" do
    it "renders error and success" do
      get :test_error
      expect(response).to have_http_status(:bad_request)
      
      allow(controller).to receive(:current_user).and_return(user)
      get :protected_action
      expect(response).to have_http_status(:ok)
    end

    it "covers authenticate_user_from_session! failure" do
      allow(controller).to receive(:current_user).and_return(nil)
      get :protected_action
      expect(response).to have_http_status(:unauthorized)
    end

    it "covers current_resource_owner and current_user" do
      token = double(resource_owner_id: user.id)
      allow(controller).to receive(:doorkeeper_token).and_return(token)
      expect(controller.send(:current_user)).to eq(user)
    end

    it "covers authorize_moderator! failure" do
      allow(controller).to receive(:current_user).and_return(user)
      get :moderator_only
      expect(response).to have_http_status(:forbidden)
    end

    it "covers authorize_moderator! success" do
      allow(controller).to receive(:current_user).and_return(moderator_user)
      get :moderator_only
      expect(response).to have_http_status(:ok)
    end
  end
end