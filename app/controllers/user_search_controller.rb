class UserSearchController < ApplicationController
  def index
    @user = User.search_by_term(params[:term]).first

    render json: @user
  end
end
