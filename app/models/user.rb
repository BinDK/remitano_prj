class User < ApplicationRecord
  has_many :youtube_videos, dependent: :destroy

  devise :database_authenticatable, :registerable, :validatable
end
