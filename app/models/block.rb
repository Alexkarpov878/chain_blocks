class Block < ApplicationRecord
  belongs_to :chain
  has_many :chain_transactions, dependent: :destroy

  validates :block_hash, presence: true, uniqueness: { scope: :chain_id }
  validates :height, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
