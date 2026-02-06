class CreateHouseholds < ActiveRecord::Migration[7.1]
  def change
    create_table :households do |t|
      t.string :wedding_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :households, :wedding_id
  end
end
