class VideoNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'video_notifications_channel'
    logger.info "#{current_user == :guest ? 'Guest' : "User #{current_user.id}"} subscribed to vid_noti_channel"
  end

  def unsubscribed
    logger.info "#{current_user == :guest ? 'Guest' : "User #{current_user.id}"} unsubscribed"
  end
end
