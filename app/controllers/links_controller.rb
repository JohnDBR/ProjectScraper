class LinksController < ApplicationController
  skip_before_action :get_current_user, only: [:open, :destroy]

  def create
    if is_current_user_member
      link = Link.new(group_id:params[:group_id].to_i)
      save_and_render link
    else
      permissions_error
    end
  end

  def open
    link = Link.where(secret:params[:link]).first
    set_user_by_token
    if @current_user
      member = Member.where(group_id:link.group_id, user_id:@current_user.id).first
      if member
        render json: {authorization: "already in"}, status: :unprocessable_entity        
      else
        Member.create(alias:params[:alias], group_id:link.group_id, user_id:@current_user.id, admin:false)
        render_ok link.destroy
      end
    elsif link
      render json: {guest: "Welcome!"}, status: :ok
    else
      permissions_error
    end
  end

  def destroy
    render_ok Link.where(secret:params[:link]).first.destroy
  end

  private 
  def is_current_user_member
    return Member.where(group_id:params[:group_id].to_i, user_id:@current_user.id).first
  end
end
