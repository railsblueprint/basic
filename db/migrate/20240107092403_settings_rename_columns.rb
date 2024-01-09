class SettingsRenameColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :settings, :alias, :key
    rename_column :settings, :set, :section
  end
end
