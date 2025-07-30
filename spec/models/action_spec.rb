# spec/models/action_spec.rb (new)
require 'rails_helper'

RSpec.describe Action, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:chain_transaction) }
  end

  describe 'validations' do
    subject { build(:action) }

    it { is_expected.to validate_presence_of(:action_type) }
    it { is_expected.to validate_numericality_of(:deposit).allow_nil.is_greater_than_or_equal_to(0).only_integer }
  end
end
