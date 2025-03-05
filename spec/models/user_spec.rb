require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { is_expected.to have_many(:youtube_videos).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end

  describe 'password encryption' do
    it 'encrypts the password' do
      expect(subject.encrypted_password).not_to eq('password123')
    end

    it 'can authenticate with the correct password' do
      expect(subject.valid_password?('password123')).to be true
    end

    it 'cannot authenticate with an incorrect password' do
      expect(subject.valid_password?('wrongpassword')).to be false
    end
  end
end
