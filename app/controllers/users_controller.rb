class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]
  before_action :is_current_user_admin, only: [:index, :create, :update, :destroy]

  def index 
    render_ok User.all
  end

  def create
    user = User.new user_params
    save_and_render user
  end

  def update 
    @user.update_attributes user_params 
    save_and_render @user
  end

  def destroy
    render_ok @user.destroy  
  end

  private 
  def set_user
    @user = User.find params[:id]
  end

  def user_params
    params.permit(
      :email,
      :password,
      :username
    )
  end
end