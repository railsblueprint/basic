class CreateMailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_templates, id: :uuid do |t|
      t.string :alias
      t.string :subject
      t.string :body
      t.string :layout
      t.boolean :not_migrated, null: false, default: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
