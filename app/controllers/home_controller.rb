class HomeController < ApplicationController
  def index
    @videos = YoutubeVideo.includes(:user).order(created_at: :desc).limit(10)
  end
end
