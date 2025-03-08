require 'rails_helper'

RSpec.describe ProcessVideoJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:url) { 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
  let(:service_result) { instance_double(ServiceResult) }
  let(:service_instance) { instance_double(YoutubeVideoExtractor) }

  before do
    allow(YoutubeVideoExtractor).to receive(:new).and_return(service_instance)
    allow(service_instance).to receive(:call).and_return(service_result)
    allow(service_result).to receive(:success?).and_return(true)
    allow(ActionCable.server).to receive(:broadcast)
  end

  it 'should queues the job in the low queue' do
    expect {
      ProcessVideoJob.perform_later(url, user)
    }.to have_enqueued_job.on_queue('low')
  end

  context 'when job is enqueue' do
    it 'should successfully initilizes youtube video extractor service' do
      expect(YoutubeVideoExtractor).to receive(:new).with(
        url: url,
        video: an_instance_of(YoutubeVideo)
      )
      expect(service_instance).to receive(:call)

      perform_enqueued_jobs do
        ProcessVideoJob.perform_later(url, user)
      end
    end

    it 'does not broadcast an error notification if successful' do
      expect(ActionCable.server).not_to receive(:broadcast).with(
        "video_notifications_user_#{user.id}",
        hash_including(type: 'error')
      )

      perform_enqueued_jobs do
        ProcessVideoJob.perform_later(url, user)
      end
    end
  end

  context 'when processing fails' do
    let(:error_message) { 'Not a valid YouTube URL' }

    before do
      allow(service_result).to receive(:success?).and_return(false)
      allow(service_result).to receive(:message).and_return(error_message)
      allow(ApplicationController.renderer).to receive(:render).and_return('<div>Error</div>')
    end

    it 'broadcasts an error notification to the user channel' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "video_notifications_user_#{user.id}",
        {
          type: 'error',
          html: '<div>Error</div>',
          current_user_id: user.id
        }
      )

      perform_enqueued_jobs do
        ProcessVideoJob.perform_later(url, user)
      end
    end

    it 'renders the notification partial with the error message' do
      expect(ApplicationController.renderer).to receive(:render).with(
        partial: 'videos/notification',
        locals: { message: "Error processing video: #{error_message}", type: 'error' }
      )

      perform_enqueued_jobs do
        ProcessVideoJob.perform_later(url, user)
      end
    end
  end
end
