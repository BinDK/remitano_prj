class ProcessVideoJob < ApplicationJob
  queue_as :low

  def perform(url, user, client_type: 'rails')
    video = user.youtube_videos.build
    video.url = url

    service = YoutubeVideoExtractor.new(url:, video:)
    result = service.call

    unless result.success?
      error_message = result.message || 'An error occurred while processing your video'
      if client_type == 'rails'
        rails_views(error_message, client_type, user)
      else
        api_client(error_message, client_type, user)
      end
    end
  end

  def api_client(error_message, client_type, user)
    broadcasting(user, {
      type: 'error',
      client_type:,
      error: error_message,
      current_user_id: user.id
    })
  end

  def rails_views(error_message, client_type, user)
    html = ApplicationController.renderer.render(
      partial: 'videos/notification',
      locals: { message: "Error processing video: #{error_message}", type: 'error' }
    )

    broadcasting(user, {
      type: 'error',
      html:,
      client_type:,
      current_user_id: user.id
    })
  end

  def broadcasting(user, payload)
    ActionCable.server.broadcast(
      "video_notifications_user_#{user.id}", payload)
  end
end
