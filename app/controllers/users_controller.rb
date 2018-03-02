class UsersController < ApplicationController
  skip_before_action :get_current_user, only: [:create]

  def index 
    render_ok User.all
  end

  def create
    user = User.new user_params
    save_and_render user
  end

  def update 
    @current_user.update_attributes user_params 
    save_and_render @current_user
  end

  def destroy
    render_ok @current_user.destroy  
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