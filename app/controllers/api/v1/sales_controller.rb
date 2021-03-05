# frozen_string_literal: true

module Api
  module V1
    # Responsible for the sales api endpoints
    class SalesController < ApplicationController
      before_action :set_sale, only: %i[update payments]
      before_action :check_products, only: %i[create]

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
          add_products_to_sale

          render json: @sale, status: 201
        else
          render json: { error: @sale.errors.full_message }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def update
        if @sale.update(sale_params)
          update_products_to_sale

          render json: @sale, status: 200
        else
          render json: { error: @sale.errors.full_message }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def payments
        @payments = @sale.payment_histories

        render json: @payments, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def add_products_to_sale
        products_params.each do |product_param|
          @sale.sale_products.create(product_param)
        end
      end

      def update_products_to_sale
        products_id = products_params.map { |product_param| product_param['product_id'] }
        @sale.sale_products.where.not(product_id: products_id).destroy_all

        products_params.each do |product_param|
          sp = @sale.sale_products.find_or_create_by(product_id: product_param['product_id'])
          sp.quantity = product_param['quantity'].to_i
          sp.save!
        end
      end

      def check_products
        render json: { error: 'Sale must have at least one product' }, status: 400 if products_params.blank?
      end

      def sale_params
        params.require(:sale).permit(:sale_date, :parcelling, :tax, :client_id)
      end

      def products_params
        params.require(:products).map { |product_params| product_params.permit(:product_id, :quantity) }
      rescue ActionController::ParameterMissing
        nil
      end

      def set_sale
        @sale = Sale.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Sale not found' }
      end
    end
  end
end
