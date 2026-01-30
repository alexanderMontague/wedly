class DropSlugFromWeddings < ActiveRecord::Migration[7.1]
  def change
    remove_index :weddings, :slug
    remove_column :weddings, :slug, :string
  end
end
