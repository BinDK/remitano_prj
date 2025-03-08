class VideoNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'video_notifications_channel'

    if current_user != :guest
      stream_from "video_notifications_user_#{current_user.id}"
      logger.info "User #{current_user.id} subscribed to personal channel"
    end

    logger.info "#{current_user == :guest ? 'Guest' : "User #{current_user.id}"} subscribed to video notifications"
  end

  def unsubscribed
    logger.info "#{current_user == :guest ? 'Guest' : "User #{current_user.id}"} unsubscribed"
  end
end
