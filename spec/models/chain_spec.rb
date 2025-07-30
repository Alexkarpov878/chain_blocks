require 'rails_helper'

describe Chain do
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
end
