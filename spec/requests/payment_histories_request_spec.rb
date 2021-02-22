require 'rails_helper'

RSpec.describe "PaymentHistories", type: :request do
  describe 'POST /payments_histories' do
    context 'valid parameters' do
      it 'should return success status' do
        payment_attributes = FactoryBot.attributer_for(:payment_history)

        post '/payment_histories', params: {
          payment_history: payment_attributes
        }

        expect(response).to have_http_status(201)
      end

      it 'should create a payment history' do
        payment_attributes = FactoryBot.attributer_for(:payment_history)

        expect {
          post '/payment_histories', params: {
            payment_history: payment_attributes
          }
        }.to change(PaymentHistory, :count)
      end
    end

    context 'invalid parameters' do
      it 'should not create a payment_history' do
        expect {
          post '/payment_histories', params: {
            payment_history: { pay_value: nil, date: nil }
          }
        }.to_not change(PaymentHistory, :count)
      end
    end
  end

  describe 'PUT /payment_histories/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        payment = create(:payment_history)

        put "/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: 1923.50 }
        }

        expect(response).to have_http_status(200)
      end

      it 'should edit the payment history' do
        payment = create(:payment_history)

        put "/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: 1923.50 }
        }

        expect(PaymentHistory.last.pay_value).to eq(1923.50)
      end
    end

    context 'invalid parameters' do
      it 'should not edit the payment_history' do
        payment = create(:payment_history)

        put "/payment_histories/#{payment.id}", params: {
          payment_history: { pay_value: nil }
        }

        expect(PaymentHistory.last.pay_value).to eq(payment.pay_value)
      end

      it 'should return payment_history not found error' do
        put '/payment_histories/999', params: {
          payment_history: { pay_value: 50 }
        }

        expect(response.body).to include('Payment history not found')
      end
    end
  end

  describe 'DELETE /payment_histories/:id' do
    context 'valid parameters' do
      it 'should return success status' do
        payment = create(:payment_history)

        delete "/payment_history/#{payment.id}"

        expect(response).to have_http_status(200)
      end

      it 'should delete the payment_history' do
        payment = create(:payment_history)
        expect(PaymentHistory.count).to eq(1)

        delete "/payment_history/#{payment.id}"
        expect(PaymentHistory.count).to eq(0)
      end
    end

    context 'invalid parameters' do
      it 'should return payment_history not found error' do
        create(:payment_history)
        expect(PaymentHistory.count).to eq(1)

        delete '/payment_history/999'
        expect(response.body).to include('Payment history not found')
        expect(PaymentHistory.count).to eq(1)
      end
    end
  end
end
