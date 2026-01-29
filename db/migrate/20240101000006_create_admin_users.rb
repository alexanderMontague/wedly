class CreateAdminUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :name

      t.timestamps
    end
  end
end
