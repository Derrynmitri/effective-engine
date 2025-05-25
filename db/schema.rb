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

ActiveRecord::Schema[8.0].define(version: 2025_05_25_080204) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "match_results", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "winner_id", null: false
    t.bigint "loser_id", null: false
    t.boolean "draw", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loser_id"], name: "index_match_results_on_loser_id"
    t.index ["match_id"], name: "index_match_results_on_match_id"
    t.index ["winner_id"], name: "index_match_results_on_winner_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "white_player_id", null: false
    t.bigint "black_player_id", null: false
    t.integer "status"
    t.datetime "played_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["black_player_id"], name: "index_matches_on_black_player_id"
    t.index ["white_player_id"], name: "index_matches_on_white_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "surname", null: false
    t.date "birthday", null: false
    t.integer "ranking"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ranking"], name: "index_players_on_ranking", unique: true
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "match_results", "matches"
  add_foreign_key "match_results", "players", column: "loser_id"
  add_foreign_key "match_results", "players", column: "winner_id"
  add_foreign_key "matches", "players", column: "black_player_id"
  add_foreign_key "matches", "players", column: "white_player_id"
  add_foreign_key "players", "users"
end
