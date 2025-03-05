FactoryBot.define do
  factory :youtube_video do
    title { 'Sample YouTube Video' }
    url { 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
    video_type { 'normal' }
    thumbnail { 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg' }
    association :user
  end
end
