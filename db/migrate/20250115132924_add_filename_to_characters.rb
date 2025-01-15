class AddFilenameToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :filename, :string
    add_index :characters, :filename, unique: true
  end
end
