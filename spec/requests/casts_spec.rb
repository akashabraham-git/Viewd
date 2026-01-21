require 'rails_helper'

RSpec.describe "Casts", type: :request do
  let!(:cast_member) { create(:cast, name: "Tom Hanks") }
  let(:moderator) { create(:moderator).user }
  let(:member) { create(:member).user }

  def sign_in_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "renders the index template" do
      get casts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tom Hanks")
    end
  end

  describe "GET /show" do
    it "renders the show template and calculates credits" do
      movie = create(:movie, title: "Cast Away")
      create(:credit, cast: cast_member, movie: movie, job: "Actor")
      
      get cast_path(cast_member)
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Actor")
      expect(response.body).to include("Cast Away")
    end
  end

  describe "POST /create" do
    let(:valid_params) { { cast: { name: "Meryl Streep", bio: "Legendary actress" } } }

    context "as a moderator" do
      before { sign_in_as(moderator) }

      it "creates a new cast member and redirects" do
        expect {
          post casts_path, params: valid_params
        }.to change(Cast, :count).by(1)
        expect(response).to redirect_to(casts_path)
        expect(flash[:notice]).to eq("Person added successfully.")
      end

      it "renders new on failure" do
        post casts_path, params: { cast: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to be_present
      end
    end
  end

  describe "GET /new" do
    context "as a moderator" do
      before { sign_in_as(moderator) }

      it "successfully initializes a new cast member" do
        get new_cast_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Add") 
      end
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(moderator) }

    it "updates and redirects" do
      patch cast_path(cast_member), params: { cast: { name: "Updated Name" } }
      expect(cast_member.reload.name).to eq("Updated Name")
      expect(response).to redirect_to(cast_path(cast_member))
    end

    it "renders edit on failure" do
      patch cast_path(cast_member), params: { cast: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit")
    end
  end

  describe "DELETE /destroy" do
    before { sign_in_as(moderator) }

    it "removes the cast member" do
      expect {
        delete cast_path(cast_member)
      }.to change(Cast, :count).by(-1)
      expect(response).to redirect_to(casts_path)
    end
  end
end