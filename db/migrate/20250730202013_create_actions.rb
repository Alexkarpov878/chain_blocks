class CreateActions < ActiveRecord::Migration[8.0]
  def change
    create_table :actions do |t|
      t.references :chain_transaction, null: false, foreign_key: true
      t.string :action_type, null: false
      t.jsonb :data, default: {}, null: false
      t.decimal :deposit, precision: 38, scale: 0
      t.datetime :executed_at, null: false

      t.timestamps
    end
    add_index :actions, :action_type
    add_index :actions, :deposit
  end
end
