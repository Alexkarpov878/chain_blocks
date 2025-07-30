FactoryBot.define do
  factory :action do
    chain_transaction
    action_type { %w[FunctionCall Transfer AddKey].sample }
    data { { from: Faker::Blockchain::Ethereum.address, to: Faker::Blockchain::Ethereum.address, amount: Faker::Number.decimal } }
    deposit { Faker::Number.between(from: 0, to: 1_000_000_000_000_000_000) }
  end
end
