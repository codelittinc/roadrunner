# frozen_string_literal: true

class CodeCommentsController < ApplicationController
  def index
    start_date = params[:start_date]
    end_date = params[:end_date]

    @code_comments = CodeComment.where(published_at: start_date..end_date)
  end
end
