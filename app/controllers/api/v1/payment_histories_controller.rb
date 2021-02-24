# frozen_string_literal: true

module Api
  module V1
    # Responsible for the payment histories api endpoints
    class PaymentHistoriesController < ApplicationController
      def create
        @payment = PaymentHistory.new(payment_params)
        if @payment.save
          render json: @payment, status: 201
        else
          render json: { error: @payment.errors.full_message }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def payment_params
        params.require(:payment_history).permit(:date, :pay_value, :sale_id)
      end
    end
  end
end
