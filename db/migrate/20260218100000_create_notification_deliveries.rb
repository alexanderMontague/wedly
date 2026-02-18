class CreateNotificationDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_deliveries do |t|
      t.references :guest, null: false, foreign_key: true
      t.string :wedding_id, null: false
      t.string :reminder_key, null: false
      t.string :channel, null: false
      t.date :scheduled_for, null: false
      t.string :status, null: false, default: "queued"
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    add_index :notification_deliveries,
              %i[guest_id wedding_id reminder_key channel],
              unique: true,
              name: "index_notification_deliveries_uniqueness"
  end
end
