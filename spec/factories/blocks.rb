FactoryBot.define do
  factory :block do
    chain
    block_hash { SecureRandom.hex(32) }
    height { Faker::Number.between(from: 1, to: 1000000) }
  end
end
