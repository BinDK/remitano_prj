class YoutubeVideo < ApplicationRecord
  self.table_name = 'videos'

  belongs_to :user

  validates :title, :thumbnail, :video_type, :url, presence: true

  after_create_commit :broadcast_video_notification

  private

  def broadcast_video_notification
    html = render_video_notification
    Rails.logger.info "Broadcasting notification: #{html.truncate(100)}"

    ActionCable.server.broadcast('video_notifications_channel', {
      type: 'new_video',
      html:,
      current_user_id: user.id
    })
  rescue StandardError => e
    Rails.logger.error "Broadcast failed: #{e.message}"
  end

  def render_video_notification
    ApplicationController.renderer.render(
      partial: 'videos/notification',
      locals: { video: self }
    )
  end
end
