# frozen_string_literal: true

module Api
  module V1
    # Responsible for the clients api endpoints
    class ClientsController < ApplicationController
      def index
        @clients = Client.order('name')

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

      private

      def client_params
        params.require(:client).permit(:name, :email, :cellphone, :description)
      end
    end
  end
end
