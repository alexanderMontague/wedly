class CreateWeddingMetadata < ActiveRecord::Migration[7.1]
  def change
    create_table :wedding_metadata, id: :uuid do |t|
      t.integer :wedding_id
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :wedding_metadata, :wedding_id
  end
end
