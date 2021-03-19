# frozen_string_literal: true

# Responsible for the authentication flow with JWT
class AuthenticationTokenService
  HMAC_SECRET = ENV['HMAC_SECRET']
  ALGORITHM_TYPE = 'HS256'

  def self.call(user_id, exp=nil)
    exp ||= Time.now.to_i + 4 * 3600
    payload = { user_id: user_id, exp: exp }

    JWT.encode payload, HMAC_SECRET, ALGORITHM_TYPE
  end
end
