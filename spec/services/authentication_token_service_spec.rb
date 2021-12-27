# frozen_string_literal: true

require 'rails_helper'

describe AuthenticationTokenService do
  describe '.call' do
    let(:user) { create(:user) }
    let(:token) { described_class.call(user.id) }
    it 'should return an authentication token' do
      decoded_token = JWT.decode(
        token, described_class::HMAC_SECRET,
        true,
        { algorithm: described_class::ALGORITHM_TYPE }
      )

      expect(decoded_token).to eq(
        [
          { 'exp' => Time.now.to_i + 4 * 3600, 'user_id' => user.id },
          { 'alg' => 'HS256' }
        ]
      )
    end
  end
end
