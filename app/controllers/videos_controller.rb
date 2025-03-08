class VideosController < ApplicationController
  before_action :require_login, except: [:index]

  def index
    @videos = YoutubeVideo.includes(:user).order(created_at: :desc)
  end

  def new
    @video = YoutubeVideo.new
  end

  def create
    @video = current_user.youtube_videos.build(youtube_video_params)
    url = youtube_video_params[:url]

    if url.present?
      ProcessVideoJob.perform_later(url, current_user)
      return redirect_to videos_path, notice: 'Video submitted and being processed!'
    end

    @video.errors.add(:base, 'URL cannot be blank')
    render :new, status: :unprocessable_entity
  end

  private

  def youtube_video_params
    params.require(:youtube_video).permit(:url)
  end

  def require_login
    unless user_signed_in?
      redirect_to root_path, alert: 'Please login or register to share videos'
    end
  end
end
