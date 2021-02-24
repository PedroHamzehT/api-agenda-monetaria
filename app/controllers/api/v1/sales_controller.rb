# frozen_string_literal: true

module Api
  module V1
    # Responsible for the sales api endpoints
    class SalesController < ApplicationController
      def index
        @sales = Sale.order('sale_date')
        @sales = @sales.where(client_id: params[:client]) if params[:client].present?

        render json: @sales, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def create
        @sale = Sale.new(sale_params)
        if @sale.save
          render json: @sale, status: 201
        else
          render json: { error: @sale.errors.full_message }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def sale_params
        params.require(:sale).permit(:sale_date, :parcelling, :tax, :client_id)
      end
    end
  end
end
