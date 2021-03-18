# frozen_string_literal: true

module Api
  module V1
    # Responsible for the clients api endpoints
    class ClientsController < ApplicationController
      before_action :user_authenticated?
      before_action :set_client, only: %i[update sales]

      def index
        @pagy, @clients = pagy(Client.order('name'))

        render json: @clients, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def create
        @client = Client.new(client_params)
        if @client.save
          render json: @client, status: 201
        else
          render json: { error: @client.errors.full_messages }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def update
        if @client.update(client_params)
          render json: @client, status: 200
        else
          render json: { error: @client.errors.full_messages }, status: 400
        end
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      def sales
        @sales = @client.sales

        render json: @sales, status: 200
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end

      private

      def client_params
        params.require(:client).permit(:name, :email, :cellphone, :description)
      end

      def set_client
        @client = Client.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: 400
      end
    end
  end
end
