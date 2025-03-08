require 'rails_helper'

RSpec.describe VideoNotificationsChannel, type: :channel do
  let!(:user) { create(:user) }

  context 'with a signed in user' do
    before { stub_connection current_user: user }

    it 'successfully subscribes to the channel' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('video_notifications_channel')
    end

    it 'subscribes to the user-specific channel' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("video_notifications_user_#{user.id}")
    end
  end

  context 'with a guest user' do
    before { stub_connection current_user: :guest }

    it 'successfully subscribes to the channel as a guest' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('video_notifications_channel')
    end

    it 'does not subscribe guest to any user-specific channel' do
      subscribe
      expect(subscription).not_to have_stream_for(/video_notifications_user_/)
    end

    it 'logs guest subscription information' do
      logger_double = double('Logger', debug: nil)
      allow_any_instance_of(described_class).to receive(:logger).and_return(logger_double)

      expect(logger_double).to receive(:info).with('Guest subscribed to video notifications')

      subscribe
    end
  end
end
