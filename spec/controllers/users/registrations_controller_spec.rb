require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:user) { create(:user) }

  describe 'DELETE #destroy' do
    context 'when user is authenticated' do
      before { sign_in user }

      context 'when Devise.sign_out_all_scopes is true' do
        it 'destroys the user resource' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          expect {
            delete :destroy
          }.to change { User.count }.by(-1)
        end

        it 'calls sign_out without resource_name argument' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          expect(controller).to receive(:sign_out).with(no_args)
          expect(controller).to receive(:set_flash_message!).with(:notice, :destroyed)
          expect(controller).to receive(:respond_with_navigational).and_call_original
          
          delete :destroy
        end

        it 'sets the flash message to destroyed' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          delete :destroy
          
          expect(flash[:notice]).to be_present
        end

        it 'redirects to after_sign_out_path_for' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          delete :destroy
          
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when Devise.sign_out_all_scopes is false' do
        it 'destroys the user resource' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(false)
          
          expect {
            delete :destroy
          }.to change { User.count }.by(-1)
        end

        it 'calls sign_out with resource_name argument' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(false)
          
          expect(controller).to receive(:sign_out).with(:user)
          expect(controller).to receive(:set_flash_message!).with(:notice, :destroyed)
          expect(controller).to receive(:respond_with_navigational).and_call_original
          
          delete :destroy
        end

        it 'sets the flash message to destroyed' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(false)
          
          delete :destroy
          
          expect(flash[:notice]).to be_present
        end

        it 'redirects to after_sign_out_path_for' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(false)
          
          delete :destroy
          
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when block is provided' do
        it 'yields resource to the block' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          yielded_resource = nil
          controller.define_singleton_method(:destroy) do
            super() { |resource| yielded_resource = resource }
          end
          
          delete :destroy
          
          expect(yielded_resource).to eq(user)
        end
      end

      context 'when block is not provided' do
        it 'does not raise error when no block is given' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          
          expect {
            delete :destroy
          }.not_to raise_error
        end
      end

      context 'when soft_delete is used (acts_as_paranoid)' do
        it 'soft deletes the user' do
          allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
          user_id = user.id
          
          delete :destroy
          
          expect(User.find_by(id: user_id)).to be_nil
          expect(User.only_deleted.find_by(id: user_id)).to eq(user)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete :destroy
        
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'integration test for destroy flow' do
    before { sign_in user }

    it 'destroys user and signs them out completely' do
      user_id = user.id
      allow(Devise).to receive(:sign_out_all_scopes).and_return(true)
      
      expect {
        delete :destroy
      }.to change { User.count }.by(-1)
      
      expect(controller.current_user).to be_nil
      expect(User.find_by(id: user_id)).to be_nil
    end

    it 'destroys user and signs out only current scope' do
      user_id = user.id
      allow(Devise).to receive(:sign_out_all_scopes).and_return(false)
      
      expect {
        delete :destroy
      }.to change { User.count }.by(-1)
      
      expect(User.find_by(id: user_id)).to be_nil
    end
  end
end
