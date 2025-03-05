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
end
