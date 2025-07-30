require 'rails_helper'

describe ChainTransaction do
  describe 'associations' do
    it { is_expected.to belong_to(:block) }
    it { is_expected.to have_many(:actions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:chain_transaction) }

    it { is_expected.to validate_presence_of(:transaction_hash) }
    it { is_expected.to validate_uniqueness_of(:transaction_hash).scoped_to(:block_id) }
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:receiver) }
    it { is_expected.to validate_presence_of(:gas_used) }
    it { is_expected.to validate_numericality_of(:gas_used).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:executed_at) }
    it { is_expected.to allow_value(true).for(:success) }
    it { is_expected.to allow_value(false).for(:success) }
    it { is_expected.not_to allow_value(nil).for(:success) }
  end

  describe 'scopes' do
    describe '.successful' do
      let!(:successful_transaction) { create(:chain_transaction, success: true) }
      let!(:failed_transaction) { create(:chain_transaction, success: false) }

      it 'returns only successful transactions' do
        expect(described_class.successful).to include(successful_transaction)
        expect(described_class.successful).not_to include(failed_transaction)
      end
    end
  end
end
