FactoryBot.define do
  factory :chain do
    name { "Coin #{SecureRandom.hex}" }
    slug { "coin-#{SecureRandom.hex}" }
    token_decimals { 24 }
    token_symbol { "Ⓝ" }
  end
end
