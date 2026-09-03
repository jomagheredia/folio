# frozen_string_literal: true

class AddSummaryToBookmarks < ActiveRecord::Migration[8.0]
  def change
    add_column :bookmarks, :summary, :text
  end
end
