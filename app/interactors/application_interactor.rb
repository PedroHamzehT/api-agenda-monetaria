# frozen_string_literal: true

class ApplicationInteractor
  include Interactor

  def validate_params!(*params)
    params.each do |param|
      raise "invalid #{param}" if param.blank?
    end
  end
end
