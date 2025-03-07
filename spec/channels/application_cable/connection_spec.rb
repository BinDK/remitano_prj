require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let!(:user) { create(:user) }

  context 'with a signed in user' do
    it 'successfully connects' do
      env = { 'warden' => double('warden', user:) }

      connect '/cable', env: env

      expect(connection.current_user).to eq user
    end
  end

  context 'with a guest user' do
    it 'successfully connects as a guest' do
      env = { 'warden' => double('warden', user: nil) }

      connect '/cable', env: env

      expect(connection.current_user).to eq :guest
    end
  end
end
