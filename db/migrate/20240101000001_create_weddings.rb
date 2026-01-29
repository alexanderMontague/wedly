class CreateWeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :weddings do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false
      t.date :date
      t.string :location
      t.json :theme_config
      t.json :settings

      t.timestamps
    end
  end
end
