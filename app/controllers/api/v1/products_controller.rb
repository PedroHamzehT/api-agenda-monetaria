# frozen_string_literal: true

module Api
  module V1
    # Responsible for the products api endpoints
    class ProductsController < ApplicationController
      def index
        @products = Product.order(:name)

        render json: @products, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end
    end
  end
end
