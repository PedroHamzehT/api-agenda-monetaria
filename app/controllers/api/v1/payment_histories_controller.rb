# frozen_string_literal: true

module Api
  module V1
    # Responsible for the payment histories api endpoints
    class PaymentHistoriesController < ApplicationController
      before_action :user_authenticated?
      before_action :set_payment, only: %i[update destroy]

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

      def update
        if @payment.update(payment_params)
          render json: @payment, status: 200
        else
          render json: { error: @payment.errors.full_message }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

        def create_update
        PaymentHistories::CreatePayments.call(payments_params)

        render json: { message: 'Pagamentos criados com sucesso!' }, status: 200
      end

      def destroy
        @payment.destroy

        render json: nil, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def payments_params
        params.require(:payment_history).permit(:sale_id, payments: %i[id pay_value date])
      end

      def payment_params
        params.require(:payment_history).permit(:date, :pay_value, :sale_id)
      end

      def set_payment
        @payment = PaymentHistory.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Payment history not found' }, status: 400
      end
    end
  end
end
