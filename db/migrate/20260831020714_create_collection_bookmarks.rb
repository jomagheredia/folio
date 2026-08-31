# frozen_string_literal: true

class CreateCollectionBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_bookmarks do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :bookmark, null: false, foreign_key: true

      t.timestamps
    end

    add_index :collection_bookmarks, [ :collection_id, :bookmark_id ], unique: true
  end
end
