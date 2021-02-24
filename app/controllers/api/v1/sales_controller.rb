# frozen_string_literal: true

module Api
  module V1
    # Responsible for the sales api endpoints
    class SalesController < ApplicationController
      def index
        @sales = Sale.order('sale_date')

        render json: @sales, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end
    end
  end
end
