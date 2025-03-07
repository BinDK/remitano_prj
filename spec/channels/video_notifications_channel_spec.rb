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
  end

  context 'with a guest user' do
    before { stub_connection current_user: :guest }

    it 'successfully subscribes to the channel as a guest' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('video_notifications_channel')
    end
  end
end
