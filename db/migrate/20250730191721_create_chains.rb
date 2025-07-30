class CreateChains < ActiveRecord::Migration[8.0]
  def change
    create_table :chains do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :token_symbol, null: false
      t.integer :token_decimals, default: 24, null: false
      t.bigint :last_processed_block_height, default: 0, null: false

      t.timestamps
    end

    add_index :chains, :name, unique: true
    add_index :chains, :slug, unique: true
  end
end
