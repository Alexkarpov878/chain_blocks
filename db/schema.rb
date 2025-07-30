# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_30_195946) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blocks", force: :cascade do |t|
    t.bigint "chain_id", null: false
    t.string "block_hash", null: false
    t.bigint "height", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chain_id", "block_hash"], name: "index_blocks_on_chain_id_and_block_hash", unique: true
    t.index ["chain_id", "height"], name: "index_blocks_on_chain_id_and_height"
    t.index ["chain_id"], name: "index_blocks_on_chain_id"
  end

  create_table "chain_transactions", force: :cascade do |t|
    t.bigint "block_id", null: false
    t.string "transaction_hash", null: false
    t.string "sender", null: false
    t.string "receiver", null: false
    t.bigint "gas_used", null: false
    t.boolean "success", default: false, null: false
    t.datetime "executed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_id", "transaction_hash"], name: "index_chain_transactions_on_block_id_and_transaction_hash", unique: true
    t.index ["block_id"], name: "index_chain_transactions_on_block_id"
    t.index ["executed_at"], name: "index_chain_transactions_on_executed_at"
  end

  create_table "chains", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "token_symbol", null: false
    t.integer "token_decimals", null: false
    t.bigint "last_processed_block_height", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_chains_on_name", unique: true
    t.index ["slug"], name: "index_chains_on_slug", unique: true
  end

  add_foreign_key "blocks", "chains"
  add_foreign_key "chain_transactions", "blocks"
end
