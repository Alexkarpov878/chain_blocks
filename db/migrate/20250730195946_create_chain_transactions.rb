class CreateChainTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :chain_transactions do |t|
      t.references :block, null: false, foreign_key: true
      t.string :transaction_hash, null: false
      t.string :sender, null: false
      t.string :receiver, null: false
      t.bigint :gas_used, precision: 30, scale: 0, null: false
      t.boolean :success, default: false, null: false
      t.datetime :executed_at, null: false

      t.timestamps
    end
    add_index :chain_transactions, [ :block_id, :transaction_hash ], unique: true
    add_index :chain_transactions, :executed_at
  end
end
