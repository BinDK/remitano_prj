require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:email) { 'test@example.com' }
  let(:password) { 'password123' }
  let(:params) { { user: { email:, password: } } }
  let(:user) { create(:user, email:, password:) }

  describe 'POST /api/v1/users/sign_in_or_sign_up' do
    context 'when user exists' do
      it 'signs in the existing user with correct password' do
        post '/api/v1/users/sign_in_or_sign_up', params: {
          user: { email: user.email, password: 'password123' }
        }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['user']['email']).to eq(user.email)
      end

      it 'returns unauthorized with incorrect password' do
        post '/api/v1/users/sign_in_or_sign_up', params: {
          user: { email: user.email, password: 'wrong_password' }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'when user does not exist' do
      let(:email) { 'new@example.com' }
      let(:password) { 'newpassword123' }

      it 'creates and signs in a new user' do
        expect {
          post '/api/v1/users/sign_in_or_sign_up', params:
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['user']['email']).to eq('new@example.com')
      end
    end
  end

  describe 'GET /api/v1/users/current' do
    context 'when user is not signed in' do
      it 'returns nil' do
        get '/api/v1/users/current'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['user']).to be_nil
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      it 'returns the current user' do
        get '/api/v1/users/current'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['email']).to eq(user.email)
      end
    end
  end

  describe 'DELETE /api/v1/users/logout' do
    context 'when user is not signed in' do
      it 'returns success false' do
        delete '/api/v1/users/logout'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      it 'logs out the user' do
        delete '/api/v1/users/logout'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
      end
    end
  end
end
