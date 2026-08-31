# frozen_string_literal: true

class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.string :title, null: false
      t.string :url
      t.text :description

      t.timestamps
    end

    add_index :bookmarks, [ :user_id, :created_at ]
    add_index :bookmarks, [ :user_id, :kind ]
    add_index :bookmarks, [ :user_id, :url ]
  end
end
