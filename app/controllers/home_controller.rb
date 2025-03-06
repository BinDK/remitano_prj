class HomeController < ApplicationController
  def index
    @videos = YoutubeVideo.includes(:user).order(created_at: :desc)
  end
end
