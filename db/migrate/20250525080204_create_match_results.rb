class CreateMatchResults < ActiveRecord::Migration[8.0]
  def change
    create_table :match_results do |t|
      t.references :match, null: false, foreign_key: true
      t.references :winner, null: false, foreign_key: { to_table: :players }
      t.references :loser, null: false, foreign_key: { to_table: :players }
      t.boolean :draw, default: false

      t.timestamps
    end
  end
end
