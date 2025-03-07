require 'open-uri'

class YoutubeVideoExtractor
  YOUTUBE_PATTERNS = [
    /youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/,
    /youtu\.be\/([a-zA-Z0-9_-]+)/,
    /youtube\.com\/shorts\/([a-zA-Z0-9_-]+)/
  ]

  def initialize(url:, video: nil)
    @url = url
    @video = video
  end

  def call
    return ServiceResult.failure('Not a valid YouTube URL') unless valid_youtube_url?

    video_info = extract_video_info

    if video_info.present? && @video
      @video.title = video_info[:title]
      @video.thumbnail = video_info[:thumbnail]
      @video.video_type = video_info[:video_type]

      if @video.save
        ServiceResult.success
      else
        ServiceResult.failure(@video.errors.full_messages.join(', '))
      end
    else
      ServiceResult.failure('Failed to extract video information')
    end
  end

  private

  attr_reader :url, :video

  def valid_youtube_url?
    YOUTUBE_PATTERNS.any? { |pattern| url =~ pattern }
  end

  def extract_video_info
    return nil unless valid_youtube_url?

    begin
      # binding.break
      response = URI.open(url)
      html_content = response.respond_to?(:read) ? response.read : response.to_s
      html_content = html_content.force_encoding('UTF-8') if html_content.present?
      doc = Nokogiri::HTML(html_content)

      title = doc.at('meta[property="og:title"]')&.attributes&.[]('content')&.value
      thumbnail = doc.at('meta[property="og:image"]')&.attributes&.[]('content')&.value
      video_type = extract_video_type(url)

      {
        title:,
        thumbnail:,
        video_type:
      }
    rescue StandardError => e
      Rails.logger.error("Error extracting video info: #{e.message}")
      nil
    end
  end

  def extract_video_type(url)
    if url.include?('youtube.com/shorts')
      'shorts'
    elsif url.include?('youtube.com/watch') || url.include?('youtu.be')
      'normal'
    else
      'unknown'
    end
  end
end
