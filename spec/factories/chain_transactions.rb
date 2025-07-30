FactoryBot.define do
  factory :chain_transaction do
    block
    transaction_hash { SecureRandom.hex(32) }
    sender { Faker::Blockchain::Ethereum.address }
    receiver { Faker::Blockchain::Ethereum.address }
    gas_used { Faker::Number.between(from: 20000, to: 1000000) }
    success { true }
    executed_at { Time.current }
  end
end
