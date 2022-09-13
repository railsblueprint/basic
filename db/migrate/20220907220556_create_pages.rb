class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages, id: :uuid do |t|
      t.string :url, index: true, unique: true
      t.string :icon
      t.string :title
      t.text :body
      t.string :seo_description
      t.string :seo_keywords
      t.string :seo_title
      t.boolean :show_in_sidebar
      t.boolean :active

      t.timestamps
    end
  end
end
