class Api::V1::VideosController < ApiController
  before_action :authenticate_user!, except: [:index]

  def index
    videos = YoutubeVideo.includes(:user).order(created_at: :desc).limit(10)
    render json: videos.as_json(include: { user: { only: %i[id email] } })
  end

  def create
    url = youtube_video_params[:url]

    if url.present?
      ProcessVideoJob.perform_later(url, current_user, client_type: 'api')
      render json: { success: true, message: 'Video submitted and being processed!' }
    else
      render_error('URL cannot be blank')
    end
  end

  private

  def youtube_video_params
    params.require(:youtube_video).permit(:url)
  end
end
