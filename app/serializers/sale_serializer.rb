class SaleSerializer < ActiveModel::Serializer
  attributes :id,
             :parcelling,
             :tax,
             :total,
             :paid,
             :sale_date,
             :client_id,
             :created_at,
             :updated_at

  def sale_date
    object.sale_date.strftime('%d/%m/%Y %H:%M:%S %z')
  end
end
