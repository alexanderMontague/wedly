class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :wedding, null: false, foreign_key: true
      t.string :name, null: false
      t.datetime :datetime
      t.string :location
      t.text :description

      t.timestamps
    end
  end
end
