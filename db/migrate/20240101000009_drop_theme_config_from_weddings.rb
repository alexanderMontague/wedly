class DropThemeConfigFromWeddings < ActiveRecord::Migration[7.1]
  def change
    remove_column :weddings, :theme_config, :json
  end
end
