class PaymentHistorySerializer < ActiveModel::Serializer
  attributes :id,
             :pay_value,
             :date,
             :sale_id,
             :created_at,
             :updated_at

  def date
    object.date.strftime('%d/%m/%Y %H:%M:%S %z')
  end
end
