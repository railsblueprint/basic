class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.string :title
      t.string :slug
      t.references :user, type: :uuid, index: true
      t.index :slug, unique: true

      t.timestamps
    end
  end
end
