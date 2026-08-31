# frozen_string_literal: true

class CreateShares < ActiveRecord::Migration[8.0]
  def change
    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :collection, foreign_key: true
      t.text :recipients, null: false, array: true, default: []
      t.text :note
      t.string :subject, null: false
      t.text :body, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end

    add_index :shares, [ :collection_id, :sent_at ]
    add_index :shares, [ :user_id, :sent_at ]

    create_table :share_bookmarks do |t|
      t.references :share, null: false, foreign_key: true
      t.references :bookmark, null: false, foreign_key: true

      t.timestamps
    end

    add_index :share_bookmarks, [ :share_id, :bookmark_id ], unique: true
  end
end
