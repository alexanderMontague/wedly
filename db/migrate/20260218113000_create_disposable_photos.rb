class CreateDisposablePhotos < ActiveRecord::Migration[7.1]
  def change
    create_table :disposable_photos, id: :uuid do |t|
      t.string :wedding_id, null: false
      t.references :guest, null: true, foreign_key: true
      t.string :object_key, null: false
      t.string :content_type, null: false
      t.integer :byte_size, null: false
      t.boolean :flash_enabled, null: false, default: false
      t.datetime :captured_at, null: false
      t.string :source_ip

      t.timestamps
    end

    add_index :disposable_photos, :object_key, unique: true
    add_index :disposable_photos, [:wedding_id, :created_at]
  end
end
