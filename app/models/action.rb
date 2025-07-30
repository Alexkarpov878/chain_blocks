class Action < ApplicationRecord
  belongs_to :chain_transaction

  validates :action_type, presence: true
  validates :data, presence: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }
end
