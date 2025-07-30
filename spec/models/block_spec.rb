require 'rails_helper'

describe Block do
  describe 'associations' do
    it { is_expected.to belong_to(:chain) }
    it { is_expected.to have_many(:chain_transactions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:block) }

    it { is_expected.to validate_presence_of(:block_hash) }
    it { is_expected.to validate_uniqueness_of(:block_hash).scoped_to(:chain_id) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than_or_equal_to(0) }
  end
end
