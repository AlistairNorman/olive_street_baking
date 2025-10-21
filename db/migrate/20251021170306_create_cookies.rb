class CreateCookies < ActiveRecord::Migration[8.0]
  def change
    create_table :cookies do |t|
      t.string :ingredients, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
