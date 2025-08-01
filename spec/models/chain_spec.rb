require 'rails_helper'

describe Chain do
  describe 'associations' do
    it { is_expected.to have_many(:blocks) }
  end

  describe 'validations' do
    subject { build(:chain) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }
    it { is_expected.to validate_presence_of(:token_decimals) }
    it { is_expected.to validate_presence_of(:token_symbol) }
  end

  describe 'defaults' do
    let(:chain) { described_class.create!(name: 'Test', slug: 'test', token_symbol: 'TST', token_decimals: 18) }

    it 'sets last_processed_block_height to 0 by default' do
      expect(chain.last_processed_block_height).to eq(0)
    end
  end

  describe '#average_gas_used' do
    subject(:average) { chain.average_gas_used }

    let(:chain) { create(:chain) }

    context 'when there are no transactions' do
      it { is_expected.to eq(0) }
    end

    context 'when there are transactions across multiple blocks' do
      before do
        block1 = create(:block, chain:)
        block2 = create(:block, chain:)

        create(:chain_transaction, block: block1, gas_used: 100)
        create(:chain_transaction, block: block1, gas_used: 200)
        create(:chain_transaction, block: block2, gas_used: 300)
      end

      it { is_expected.to eq(200) }
    end
  end
end
