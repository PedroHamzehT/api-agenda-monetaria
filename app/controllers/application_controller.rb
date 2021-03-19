class ApplicationController < ActionController::API
  include Pagy::Backend

  def user_authenticated?
    return render json: { error: 'User unauthenticated' }, status: 401 if request.headers['Authorization'].blank?

    token_type, token = request.headers['Authorization'].split(' ')
    return render json: { error: 'Wrong token' }, status: 401 if token_type != 'Bearer'

    decoded_token = JWT.decode(
      token,
      AuthenticationTokenService::HMAC_SECRET,
      true,
      { algorithm: AuthenticationTokenService::ALGORITHM_TYPE }
    )

    session[:user_id] = decoded_token.first['user_id']
  rescue JWT::ExpiredSignature
    render json: { error: 'User token expired' }, status: 401
  end
end
