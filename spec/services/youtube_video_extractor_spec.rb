require 'rails_helper'

RSpec.describe YoutubeVideoExtractor do
  let(:valid_youtube_url) { 'https://www.youtube.com/watch?v=abc123' }
  let(:invalid_url) { 'https://example.com' }
  let(:video) { create(:youtube_video) }
  let(:title) { 'Example Video Title' }
  let(:thumbnail) { 'https://example.com/thumbnail.jpg' }
  let(:html) do
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
    allow(URI).to receive(:open).and_return(html)
  end

  describe '#call' do
    context 'with a valid YouTube URL and video' do
      it 'updates the video attributes and returns a success result' do
        extractor = described_class.new(url: valid_youtube_url, video: video)
        result = extractor.call

        expect(result.success?).to be true
        expect(video.title).to eq('Example Video Title')
        expect(video.thumbnail).to eq('https://example.com/thumbnail.jpg')
        expect(video.video_type).to eq('normal')
      end
    end

    context 'with an invalid YouTube URL' do
      it 'returns a failure result' do
        extractor = described_class.new(url: invalid_url, video: video)
        result = extractor.call

        expect(result.success?).to be false
        expect(result.message).to eq('Not a valid YouTube URL')
      end
    end

    context 'when video info extraction fails' do
      it 'returns a failure result' do
        allow_any_instance_of(described_class).to receive(:extract_video_info).and_return(nil)

        extractor = described_class.new(url: valid_youtube_url, video: video)
        result = extractor.call

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to extract video information')
      end
    end

    context 'when video save fails' do
      it 'returns a failure result with the error message' do
        allow(video).to receive(:save).and_return(false)
        allow(video).to receive_message_chain(:errors, :full_messages).and_return(['Title cannot be blank'])

        extractor = described_class.new(url: valid_youtube_url, video: video)
        result = extractor.call

        expect(result.success?).to be false
        expect(result.message).to eq('Title cannot be blank')
      end
    end
  end

  describe '#valid_youtube_url?' do
    context 'with valid YouTube URLs' do
      it 'returns true for youtube.com/watch URLs' do
        extractor = described_class.new(url: 'https://www.youtube.com/watch?v=abc123')
        expect(extractor.send(:valid_youtube_url?)).to be true
      end

      it 'returns true for youtu.be URLs' do
        extractor = described_class.new(url: 'https://youtu.be/abc123')
        expect(extractor.send(:valid_youtube_url?)).to be true
      end

      it 'returns true for youtube.com/shorts URLs' do
        extractor = described_class.new(url: 'https://www.youtube.com/shorts/abc123')
        expect(extractor.send(:valid_youtube_url?)).to be true
      end
    end

    context 'with invalid URLs' do
      it 'returns false for non-YouTube URLs' do
        extractor = described_class.new(url: invalid_url)
        expect(extractor.send(:valid_youtube_url?)).to be false
      end

      it 'returns false for malformed YouTube URLs' do
        extractor = described_class.new(url: 'https://www.youtube.com/invalid')
        expect(extractor.send(:valid_youtube_url?)).to be false
      end
    end
  end

  describe '#extract_video_info' do
    context 'with a valid YouTube URL' do
      before { allow(URI).to receive(:open).and_return(html) }

      it 'extracts video metadata successfully' do
        extractor = described_class.new(url: valid_youtube_url)
        video_info = extractor.send(:extract_video_info)

        expect(video_info[:title]).to eq('Example Video Title')
        expect(video_info[:thumbnail]).to eq('https://example.com/thumbnail.jpg')
        expect(video_info[:video_type]).to eq('normal')
      end

      context 'when og:title is Japanese' do
        let(:title) { '日本語のビデオタイトル' }

        it 'properly handles UTF-8 encoded titles' do
          extractor = described_class.new(url: valid_youtube_url)
          video_info = extractor.send(:extract_video_info)

          expect(video_info[:title]).to eq('日本語のビデオタイトル')
          expect(video_info[:thumbnail]).to eq('https://example.com/thumbnail.jpg')
          expect(video_info[:video_type]).to eq('normal')
        end
      end
    end

    context 'when URL is invalid' do
      it 'should returns nil' do
        extractor = described_class.new(url: invalid_url)
        expect(extractor.send(:extract_video_info)).to be_nil
      end
    end

    context 'when network errors occur, or something else went wrong' do
      before do
        allow(URI).to receive(:open).and_raise(StandardError.new('Failed to open URL'))
      end

      it 'returns nil if the URL is invalid' do
        extractor = described_class.new(url: invalid_url)
        expect(extractor.send(:extract_video_info)).to be_nil
      end

      it 'logs an error and returns nil if an exception occurs' do
        extractor = described_class.new(url: valid_youtube_url)
        expect(Rails.logger).to receive(:error).with(/Error extracting video info/)
        expect(extractor.send(:extract_video_info)).to be_nil
      end
    end
  end
end
