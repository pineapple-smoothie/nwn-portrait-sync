class AddServerToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_reference :characters, :server, null: false, foreign_key: true
  end
end
