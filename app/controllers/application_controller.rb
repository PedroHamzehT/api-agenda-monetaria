# frozen_string_literal: true

class ApplicationController < ActionController::API # rubocop:disable Style/Documentation
  include Pagy::Backend

  def user_authenticated?
    return render json: { error: 'User unauthenticated' }, status: 401 if request.headers['Authorization'].blank?

    token_type, token = request.headers['Authorization'].split(' ')
    return render json: { error: 'Wrong token' }, status: 401 if token_type != 'Bearer'

    add_session_user_id(token)
  rescue JWT::ExpiredSignature
    render json: { error: 'User token expired' }, status: 401
  rescue StandardError => e
    render json: { error: e.message }, status: 500
  end

  private

  def add_session_user_id(token)
    session[:user_id] = decode_token(token).first['user_id']
  end

  def decode_token(token)
    JWT.decode(
      token,
      AuthenticationTokenService::HMAC_SECRET,
      true,
      { algorithm: AuthenticationTokenService::ALGORITHM_TYPE }
    )
  end
end
