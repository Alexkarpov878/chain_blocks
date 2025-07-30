class CreateBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :blocks do |t|
      t.references :chain, null: false, foreign_key: true
      t.string :block_hash, null: false
      t.bigint :height, null: false

      t.timestamps
    end
    add_index :blocks, [ :chain_id, :block_hash ], unique: true
    add_index :blocks, [ :chain_id, :height ]
  end
end
