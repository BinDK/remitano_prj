require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { { youtube_video: { url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' } } }
  let(:invalid_attributes) { { youtube_video: { url: 'invalid-url' } } }

  let(:title) { 'Example Video Title' }
  let(:thumbnail) { 'https://example.com/thumbnail.jpg' }
  let(:mocked_html) do
    <<-HTML
    <html>
      <head>
        <meta property="og:title" content="#{title}" />
        <meta property="og:image" content="#{thumbnail}" />
      </head>
    </html>
    HTML
  end

  before do
    allow(URI).to receive(:open).with(any_args).and_return(StringIO.new(mocked_html))
  end

  describe 'POST /videos' do
    context 'when user is logged in' do
      before { sign_in user }

      context 'with valid params' do
        it 'creates a new YoutubeVideo and redirects to the videos index', focus: true do
          expect {
            post videos_path, params: valid_attributes
          }.to change(YoutubeVideo, :count).by(1)

          expect(response).to redirect_to(videos_path)
          follow_redirect!
          expect(response.body).to include('Video was successfully shared!')
        end
      end

      context 'with invalid params' do
        it 'does not create a new YoutubeVideo and re-renders the new template' do
          expect {
            post videos_path, params: invalid_attributes
          }.not_to change(YoutubeVideo, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Share Video')
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
