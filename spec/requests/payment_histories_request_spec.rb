# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PaymentHistories', type: :request do
  describe 'POST /payments_histories' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }
    let(:payment_history_attributes) { FactoryBot.attributes_for(:payment_history) }

    context 'valid parameters' do
      let(:payments_body) do
        {
          payment_history: {
            sale_id: payment_history_attributes[:sale_id],
            payments: [
              {
                pay_value: payment_history_attributes[:pay_value],
                date: payment_history_attributes[:date]
              }
            ]
          }
        }
      end

      it 'should return success status' do
        post '/api/v1/payments', params: payments_body, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should create a payment history' do
        expect do
          post '/api/v1/payments', params: payments_body, headers: {
            Authorization: "Bearer #{token}"
          }
        end.to change(PaymentHistory, :count)
      end
    end

    context 'invalid parameters' do
      let(:payments_body) do
        {
          payment_history: {
            sale_id: payment_history_attributes[:sale_id],
            payments: [
              {
                pay_value: nil,
                date: nil
              }
            ]
          }
        }
      end

      it 'should not create a payment_history' do
        expect do
          post '/api/v1/payments', params: payments_body, headers: {
            Authorization: "Bearer #{token}"
          }
        end.to_not change(PaymentHistory, :count)
      end
    end
  end

  describe 'PUT /api/v1/payment_histories/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        payment = create(:payment_history)

        put "/api/v1/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: 1923.50 }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should edit the payment history' do
        payment = create(:payment_history)

        put "/api/v1/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: 1923.50 }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(PaymentHistory.last.pay_value).to eq(1923.50)
      end
    end

    context 'invalid parameters' do
      it 'should not edit the payment_history' do
        payment = create(:payment_history)

        put "/api/v1/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: nil }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(PaymentHistory.last.pay_value).to eq(payment.pay_value)
      end

      it 'should return payment_history not found error' do
        put '/api/v1/payment_histories/999', params: {
          payment_history: { pay_value: 50 }
        }, headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response.body).to include('Payment history not found')
      end
    end
  end

  describe 'DELETE /api/v1/payment_histories/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationTokenService.call(user.id) }

    context 'valid parameters' do
      it 'should return success status' do
        payment = create(:payment_history)

        delete "/api/v1/payment_histories/#{payment.id}", headers: {
          Authorization: "Bearer #{token}"
        }

        expect(response).to have_http_status(200)
      end

      it 'should delete the payment_history' do
        payment = create(:payment_history)
        expect(PaymentHistory.count).to eq(1)

        delete "/api/v1/payment_histories/#{payment.id}", headers: {
          Authorization: "Bearer #{token}"
        }
        expect(PaymentHistory.count).to eq(0)
      end
    end

    context 'invalid parameters' do
      it 'should return payment_history not found error' do
        create(:payment_history)
        expect(PaymentHistory.count).to eq(1)

        delete '/api/v1/payment_histories/999', headers: {
          Authorization: "Bearer #{token}"
        }
        expect(response.body).to include('Payment history not found')
        expect(PaymentHistory.count).to eq(1)
      end
    end
  end
end
