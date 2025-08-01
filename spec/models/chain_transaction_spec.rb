require 'rails_helper'

describe ChainTransaction, type: :model do
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
      let!(:successful_tx) { create(:chain_transaction, success: true) }
      let!(:failed_tx) { create(:chain_transaction, success: false) }

      it 'includes successful transactions' do
        expect(described_class.successful).to include(successful_tx)
      end

      it 'excludes failed transactions' do
        expect(described_class.successful).not_to include(failed_tx)
      end

      context 'when no successful transactions exist' do
        before { described_class.where(success: true).destroy_all }

        it 'returns an empty relation' do
          expect(described_class.successful).to be_empty
        end
      end
    end

    describe '.displayable_transfers' do
      subject(:results) { described_class.displayable_transfers }

      let(:block_one) { create(:block, height: 100) }
      let(:block_two) { create(:block, height: 200) }

      let!(:tx_with_multi_transfers) { create(:chain_transaction, block: block_one) }
      let!(:tx_with_single_transfer) { create(:chain_transaction, block: block_two) }
      let!(:tx_without_transfer) { create(:chain_transaction, block: block_one) }
      let!(:tx_with_failed_transfer) { create(:chain_transaction, block: block_one, success: false) }

      before do
        create(:action, chain_transaction: tx_with_multi_transfers, action_type: 'Transfer', deposit: 100)
        create(:action, chain_transaction: tx_with_multi_transfers, action_type: 'Transfer', deposit: 200)
        create(:action, chain_transaction: tx_with_single_transfer, action_type: 'Transfer', deposit: 150)
        create(:action, chain_transaction: tx_without_transfer, action_type: 'FunctionCall', deposit: 0)
        create(:action, chain_transaction: tx_with_failed_transfer, action_type: 'Transfer', deposit: 50)
      end


      it 'includes only transactions with transfer actions' do
        expect(described_class.displayable_transfers.pluck(:id)).to contain_exactly(
          tx_with_multi_transfers.id,
          tx_with_single_transfer.id,
          tx_with_failed_transfer.id
        )
      end

      it 'aggregates total deposit per transaction' do
        expect(results.find(tx_with_multi_transfers.id).total_deposit).to eq(300)
        expect(results.find(tx_with_single_transfer.id).total_deposit).to eq(150)
        expect(results.find(tx_with_failed_transfer.id).total_deposit).to eq(50)
      end

      context 'when no transfer actions exist' do
        before { Action.where(action_type: 'Transfer').destroy_all }

        it 'returns an empty relation' do
          expect(results).to be_empty
        end
      end
    end
  end
end
