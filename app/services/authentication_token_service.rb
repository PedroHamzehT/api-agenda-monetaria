# frozen_string_literal: true

# Responsible for the authentication flow with JWT
class AuthenticationTokenService
  HMAC_SECRET = ENV['HMAC_SECRET']
  ALGORITHM_TYPE = 'HS256'

  def self.call(user_id)
    payload = { user_id: user_id }

    JWT.encode payload, HMAC_SECRET, ALGORITHM_TYPE
  end
end
