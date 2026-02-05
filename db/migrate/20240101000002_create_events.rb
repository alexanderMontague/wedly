class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.integer :wedding_id, null: false
      t.string :name, null: false
      t.datetime :datetime
      t.string :location
      t.text :description

      t.timestamps
    end

    add_index :events, :wedding_id
  end
end
