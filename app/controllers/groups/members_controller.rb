class MembersController < ApplicationController
  before_action :set_group, only: [:index, :create, :update, :destroy]
  before_action :set_member, only: [:show, :update, :destroy]

  def show
    if is_a_group_member?
      render_ok @member.user
    else
      permissions_error
    end
  end

  def index
    if is_current_user_member?
      render_ok @group.members
    else
      permissions_error
    end
  end

  def create
    if is_group_admin?
      params[:email] ||= ''
      params[:username] ||= ''
      user = User.find_by(email: params[:email].downcase)
      user = User.find_by(username: params[:username].downcase) unless user
      if user
        member = Member.new(group_id:@group.id, user_id:user.id, alias:params[:alias], admin:params[:admin])
        save_and_render member
      else
        render json: {single_authentication: 'invalid credentials'}, status: :unauthorized 
      end
    else
      permissions_error
    end
  end

  def update 
    if is_group_admin? and is_a_group_member?
      @member.update_attributes(alias:params[:alias], admin:params[:admin])
      save_and_render @member
    elsif @member.user.id == @current_user.id
      @member.update_attribute(:alias, params[:alias])
      save_and_render @member
    else
      permissions_error
    end
  end

  def destroy
    if is_group_admin? and is_a_group_member?
      render_ok @member.destroy  
    elsif @member.user.id == @current_user.id
      render_ok @member.destroy  
    else
      permissions_error
    end
  end

  private 
  def set_group
    @group = @current_user.groups.find params[:group_id]
  end

  def set_member
    @member = Member.find params[:id]
  end

  def is_current_user_member?
    return Member.where(group_id:@group.id, user_id:@current_user.id)
  end

  def is_group_admin?
    return Member.where(group_id:@group.id, user_id:@current_user.id).admin
  end

  def is_a_group_member?
    return @member.group.id == params[:group_id]
  end
end
