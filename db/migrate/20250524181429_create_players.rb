class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :surname, null: false
      t.date :birthday, null: false
      t.integer :ranking

      t.timestamps
    end

    add_index :players, :ranking, unique: true
  end
end
