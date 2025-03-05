class YoutubeVideo < ApplicationRecord
  self.table_name = 'videos'

  belongs_to :user

  validates :title, :thumbnail, :video_type, :url, presence: true
end
