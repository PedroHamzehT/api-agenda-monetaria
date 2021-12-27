# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  context 'valid values' do
    it 'should create client' do
      create(:client)

      expect(Client.all.size).to eq(1)
    end
  end

  context 'invalid values' do
    it 'name blank should not be valid' do
      client = build(:client, name: '')

      expect(client).to_not be_valid
    end
  end
end
