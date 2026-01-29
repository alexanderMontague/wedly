class CreateRsvps < ActiveRecord::Migration[7.1]
  def change
    create_table :rsvps do |t|
      t.references :guest, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.string :meal_choice
      t.text :dietary_restrictions
      t.text :notes

      t.timestamps
    end

    add_index :rsvps, [:guest_id, :status]
  end
end
