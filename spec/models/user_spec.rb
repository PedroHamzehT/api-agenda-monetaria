require 'rails_helper'

RSpec.describe User, type: :model do
  context 'valid values' do
    it 'should create the user'

    it 'the user password should be encrypted'
  end

  context 'invalid values' do
    it 'should not create the user when email is missing'

    it 'should not create the user when name is missing'

    it 'should not create the user when email already exists'

    it 'should not create the user when password is missing'
  end
end
