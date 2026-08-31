# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    redirect_to bookmarks_path
  end
end
