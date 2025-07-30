class ChainTransaction < ApplicationRecord
  belongs_to :block
  has_many :actions, dependent: :destroy

  validates :transaction_hash, presence: true, uniqueness: { scope: :block_id }
  validates :sender, presence: true
  validates :receiver, presence: true
  validates :executed_at, presence: true
  validates :success, inclusion: { in: [ true, false ] }
  validates :gas_used, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :successful, -> { where(success: true) }
end
