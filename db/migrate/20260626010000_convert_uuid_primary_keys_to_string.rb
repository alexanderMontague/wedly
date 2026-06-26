class ConvertUuidPrimaryKeysToString < ActiveRecord::Migration[7.1]
  # SQLite has no native `uuid` type. These tables were created with `id: :uuid`,
  # which SQLite stores as text but which the schema dumper cannot represent,
  # leaving db/schema.rb uncommentable and unloadable. UUIDs are assigned in Ruby
  # via UuidPrimaryKey, so a string primary key is the correct, dumpable type.
  #
  # Both tables are empty in every environment, so recreating them is lossless.
  def up
    return unless uuid_primary_key?(:wedding_metadata) || uuid_primary_key?(:disposable_photos)

    drop_table :disposable_photos, if_exists: true
    drop_table :wedding_metadata, if_exists: true

    create_table :wedding_metadata, id: :string do |t|
      t.string :wedding_id
      t.string :key
      t.string :value

      t.timestamps
    end
    add_index :wedding_metadata, :wedding_id

    create_table :disposable_photos, id: :string do |t|
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
    add_index :disposable_photos, %i[wedding_id created_at]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def uuid_primary_key?(table)
    return false unless table_exists?(table)

    column = columns(table).find { |c| c.name == "id" }
    column&.sql_type == "uuid"
  end
end
