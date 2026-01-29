class CreateGuests < ActiveRecord::Migration[7.1]
  def change
    create_table :guests do |t|
      t.references :wedding, null: false, foreign_key: true
      t.references :household, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :invite_code, null: false, index: { unique: true }
      t.text :address
      t.string :phone_number

      t.timestamps
    end
  end
end
