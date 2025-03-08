require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:user) { create(:user) }
  let(:url) { 'https://www.youtube.com/watch?v=JQowMIY2bOw'}
  let(:params) { { youtube_video: { url: } } }

  describe 'POST /videos' do
    context 'when user is logged in' do
      before { sign_in user }

      context 'with valid params' do
        it 'should enqueues a ProcessVideoJob and redirects to the videos index reight away' do
          expect {
            post videos_path, params:
          }.to have_enqueued_job(ProcessVideoJob).with(params[:youtube_video][:url], user)

          expect(response).to redirect_to(videos_path)
          follow_redirect!
          expect(response.body).to include('Video submitted and being processed!')
        end
      end

      context 'with blank URL' do
        let(:url) { '' }

        it 'does not enqueue a job and re-renders the new template' do
          expect {
            post videos_path, params:
          }.not_to have_enqueued_job(ProcessVideoJob)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('URL cannot be blank')
        end
      end

      context 'with invalid URL' do
        let(:url) { 'invalid-url' }

        it 'enqueues a job to be validated in the background' do
          expect {
            post videos_path, params:
          }.to have_enqueued_job(ProcessVideoJob)

          expect(response).to redirect_to(videos_path)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to the root path with an alert' do
        post videos_path, params: params

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Please login or register to share videos')
      end
    end
  end
end
