# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :notes
      t.text :ai_summary

      t.timestamps
    end

    add_index :collections, [ :user_id, :name ]
  end
end
