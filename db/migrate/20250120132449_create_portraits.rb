class CreatePortraits < ActiveRecord::Migration[8.0]
  def change
    create_table :portraits do |t|
      t.references :character, null: false, foreign_key: true
      t.integer :size, null: false, default: 0

      t.timestamps
    end
  end
end
