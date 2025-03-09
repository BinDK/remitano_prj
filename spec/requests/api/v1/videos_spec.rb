require 'rails_helper'

RSpec.describe 'Api::V1::Videos', type: :request do
  let(:user) { create(:user) }
  let(:params) { { youtube_video: { url: } } }
  let(:url) { 'https://www.youtube.com/watch?v=fI569nw0YUQ' }
  let!(:videos) { create_list(:youtube_video, 3, user: user) }

  describe 'GET /api/v1/videos' do
    it 'returns a list of videos' do
      get '/api/v1/videos'

      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
      expect(json_response.first).to include('title', 'thumbnail', 'url')
      expect(json_response.first['user']).to include('id', 'email')
    end
  end

  describe 'POST /api/v1/videos' do
    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/videos', params: params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You need to sign in before continuing')
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid params' do
        it 'enqueues a ProcessVideoJob with the API client type' do
          expect {
            post '/api/v1/videos', params:
          }.to have_enqueued_job(ProcessVideoJob)
            .with('https://www.youtube.com/watch?v=fI569nw0YUQ', user, client_type: 'api')

          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to eq(true)
          expect(json_response['message']).to eq('Video submitted and being processed!')
        end
      end

      context 'with invalid params' do
        let(:url) { '' }

        it 'returns an error if URL is blank' do
          post '/api/v1/videos', params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('URL cannot be blank')
        end
      end
    end
  end
end
