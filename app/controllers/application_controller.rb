class ApplicationController < ActionController::API
  include Pagy::Backend

  def user_authenticated?
    return render json: { error: 'User unauthenticated' }, status: 401 if request.headers['Authorization'].blank?

    token = request.headers['Authorization'].split(' ').last
    decoded_token = JWT.decode(
      token,
      AuthenticationTokenService::HMAC_SECRET,
      true,
      { algorithm: AuthenticationTokenService::ALGORITHM_TYPE }
    )

    session[:user_id] = decoded_token.first['user_id']
  end
end
