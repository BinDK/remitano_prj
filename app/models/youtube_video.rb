class YoutubeVideo < ApplicationRecord
  self.table_name = 'videos'

  YOUTUBE_PATTERNS = [
    /youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/,
    /youtu\.be\/([a-zA-Z0-9_-]+)/,
    /youtube\.com\/shorts\/([a-zA-Z0-9_-]+)/
  ]

  belongs_to :user

  validates :title, :thumbnail, :video_type, :url, presence: true

  after_create_commit :broadcast_video_notification

  private

  def broadcast_video_notification
    html = render_video_notification
    card = render_video_card

    Rails.logger.info "Broadcasting notification: #{html.truncate(100)}"

    ActionCable.server.broadcast('video_notifications_channel', {
      type: 'new_video',
      html:,
      current_user_id: user.id,
      card:
    })
  rescue StandardError => e
    Rails.logger.error "Broadcast failed: #{e.message}"
  end

  def render_video_notification
    ApplicationController.renderer.render(
      partial: 'videos/notification',
      locals: { message: "#{user.email} shared a new video: #{title.truncate(40)}", type: 'success' }
    )
  end

  def render_video_card
    ApplicationController.renderer.render(
      partial: 'videos/video',
      locals: { video: self }
    )
  end
end
