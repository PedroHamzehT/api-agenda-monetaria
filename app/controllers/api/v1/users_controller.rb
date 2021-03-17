# frozen_string_literal: true

module Api
  module V1
    # Controller responsible to sign_up, sign_in and update the users
    class UsersController < ApplicationController
      def sign_up
        @user = User.new(user_params)
        if @user.save
          token = AuthenticationTokenService.call(@user.id)
          render json: { token: token }, status: 201
        else
          render json: { error: @user.errors.full_messages }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def sign_in; end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
