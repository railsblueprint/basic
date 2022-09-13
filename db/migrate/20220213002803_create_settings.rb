class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :alias, null: false
      t.string :description
      t.integer :type, null: false, default: 0
      t.string :value
      t.string :set
      t.boolean :not_migrated, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
