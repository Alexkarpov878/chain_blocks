class Chain < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :token_decimals, presence: true
end
