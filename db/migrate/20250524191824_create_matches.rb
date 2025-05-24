class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :white_player, null: false, foreign_key: { to_table: :players }
      t.references :black_player, null: false, foreign_key: { to_table: :players }
      t.integer :status
      t.datetime :played_at

      t.timestamps
    end
  end
end
