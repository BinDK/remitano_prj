class ProcessVideoJob < ApplicationJob
  queue_as :low

  def perform(url, user)
    video = user.youtube_videos.build
    video.url = url

    service = YoutubeVideoExtractor.new(url:, video:)
    result = service.call

    unless result.success?
      error_message = result.message || 'An error occurred while processing your video'
      html = ApplicationController.renderer.render(
        partial: 'videos/notification',
        locals: { message: "Error processing video: #{error_message}", type: 'error' }
      )

      ActionCable.server.broadcast(
        "video_notifications_user_#{user.id}",
        {
          type: 'error',
          html:,
          current_user_id: user.id
        }
      )
    end
  end
end
