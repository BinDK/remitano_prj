require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { { youtube_video: { url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' } } }
  let(:invalid_attributes) { { youtube_video: { url: 'invalid-url' } } }

  describe 'POST /videos' do
    context 'when user is logged in' do
      before { sign_in user }

      context 'with valid params' do
        it 'should enqueues a ProcessVideoJob and redirects to the videos index reight away' do
          expect {
            post videos_path, params: valid_attributes
          }.to have_enqueued_job(ProcessVideoJob).with(valid_attributes[:youtube_video][:url], user)

          expect(response).to redirect_to(videos_path)
          follow_redirect!
          expect(response.body).to include('Video submitted and being processed!')
        end
      end

      context 'with blank URL' do
        it 'does not enqueue a job and re-renders the new template' do
          blank_url_attributes = { youtube_video: { url: '' } }

          expect {
            post videos_path, params: blank_url_attributes
          }.not_to have_enqueued_job(ProcessVideoJob)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('URL cannot be blank')
        end
      end

      context 'with invalid URL' do
        it 'enqueues a job to be validated in the background' do
          expect {
            post videos_path, params: invalid_attributes
          }.to have_enqueued_job(ProcessVideoJob)

          expect(response).to redirect_to(videos_path)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to the root path with an alert' do
        post videos_path, params: valid_attributes
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Please login or register to share videos')
      end
    end
  end
end
