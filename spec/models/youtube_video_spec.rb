require 'rails_helper'

RSpec.describe YoutubeVideo, type: :model do
  subject { build(:youtube_video) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:thumbnail) }
    it { should validate_presence_of(:video_type) }
  end

  describe 'callbacks' do
    it 'calls broadcast_video_notification after create' do
      youtube_video = build(:youtube_video)
      expect(youtube_video).to receive(:broadcast_video_notification)
      youtube_video.save
    end
  end

  describe '#broadcast_video_notification' do
    let(:youtube_video) { create(:youtube_video) }
    let(:html) { '<div>Test notification</div>' }
    let(:logger_double) { double('Logger') }

    it 'should broadcasts to the video_notifications_channel' do
      allow(youtube_video).to receive(:render_video_notification).and_return(html)

      expect(ActionCable.server).to receive(:broadcast).with(
        'video_notifications_channel',
        {
          type: 'new_video',
          html:,
          current_user_id: youtube_video.user.id
        }
      )

      youtube_video.send(:broadcast_video_notification)
    end

    it 'should handles exceptions' do
      allow(youtube_video).to receive(:render_video_notification).and_raise(StandardError.new('Test error'))
      allow(Rails).to receive(:logger).and_return(logger_double)

      expect(logger_double).to receive(:error).with('Broadcast failed: Test error')
      expect {
        youtube_video.send(:broadcast_video_notification)
      }.not_to raise_error
    end
  end
end
