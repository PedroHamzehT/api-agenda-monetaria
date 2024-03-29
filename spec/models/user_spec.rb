# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'valid values' do
    it 'should create the user' do
      User.create(name: 'User', email: 'user@example.com', password: 'password', password_confirmation: 'password')

      expect(User.count).to eq(1)
    end

    it 'the user password should be encrypted' do
      user = User.create(name: 'User', email: 'user@example.com', password: 'password',
                         password_confirmation: 'password')

      expect(user.password_digest).to_not eq('password')
    end
  end

  context 'invalid values' do
    it 'should not create the user when email is missing' do
      user = build(:user, email: nil)

      expect(user).to_not be_valid
    end

    it 'should not create the user when name is missing' do
      user = build(:user, name: nil)

      expect(user).to_not be_valid
    end

    it 'should not create the user when email already exists' do
      create(:user, email: 'user@example.com')
      user = build(:user, email: 'user@example.com')

      expect(user).to_not be_valid
    end

    it 'should not create the user when password is missing' do
      user = build(:user, password: nil)

      expect(user).to_not be_valid
    end
  end
end
