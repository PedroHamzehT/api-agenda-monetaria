# frozen_string_literal: true

module Api
  module V1
    # Responsible for the products api endpoints
    class ProductsController < ApplicationController
      before_action :user_authenticated?
      before_action :set_product, only: %i[update]

      def index
        @products = Product.where(user_id: session[:user_id]).order(:name)

        render json: @products, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def create
        @product = Product.new(product_params.merge({ user_id: session[:user_id] }))
        if @product.save
          render json: @product, status: 201
        else
          render json: { error: @product.errors.full_messages }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def update
        if @product.update(product_params)
          render json: @product, status: 200
        else
          render json: { error: @product.errors.full_messages }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def product_params
        params.require(:product).permit(:name, :value, :description)
      end

      def set_product
        @product = Product.find_by(id: params[:id], user_id: session[:user_id])

        return render json: { error: 'Product not found' }, status: 400 if @product.blank?
      end
    end
  end
end
