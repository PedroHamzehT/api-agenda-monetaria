# frozen_string_literal: true

module Api
  module V1
    # Responsible for the clients api endpoints
    class ClientsController < ApplicationController
      def index
        @clients = Client.order('name')

        render json: @clients, status: 201
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end
    end
  end
end
