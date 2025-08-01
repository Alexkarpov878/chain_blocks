class Chain < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :token_decimals, presence: true
  validates :token_symbol, presence: true

  has_many :blocks, dependent: :destroy
  has_many :chain_transactions, through: :blocks

  def average_gas_used
    chain_transactions.average(:gas_used).to_i
  end
end
