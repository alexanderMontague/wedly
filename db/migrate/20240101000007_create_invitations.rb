class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :guest, null: false, foreign_key: true
      t.datetime :sent_at
      t.datetime :opened_at
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
