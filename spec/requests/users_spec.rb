require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /users/sign_in_or_sign_up' do
    it "creates a new user when email doesn't exist" do
      expect do
        post '/users/sign_in_or_sign_up', params: { user: { email: 'test@example.com', password: 'password123' } }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include('Account created')
    end

    it 'signs in an existing user' do
      create(:user, email: 'existing@example.com', password: 'password123')

      post '/users/sign_in_or_sign_up', params: { user: { email: 'existing@example.com', password: 'password123' } }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include('Signed in')
    end

    it 'does not sign in an existing user with invalid password' do
      create(:user, email: 'existing@example.com', password: 'password123')

      post '/users/sign_in_or_sign_up', params: { user: { email: 'existing@example.com', password: 'wrongpassword' } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Invalid email or password')
    end

    it 'does not create a new user with invalid email' do
      expect do
        post '/users/sign_in_or_sign_up', params: { user: { email: 'invalid-email', password: 'password123' } }
      end.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Error creating account')
    end

    it 'does not create a new user without a password' do
      expect do
        post '/users/sign_in_or_sign_up', params: { user: { email: 'test@example.com', password: '' } }
      end.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Error creating account')
    end

    it 'does not create a new user without an email' do
      expect do
        post '/users/sign_in_or_sign_up', params: { user: { email: '', password: 'password123' } }
      end.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Error creating account')
    end
  end
end
