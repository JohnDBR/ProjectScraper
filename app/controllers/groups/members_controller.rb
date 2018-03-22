class MembersController < ApplicationController
  before_action :set_group, only: [:index, :create, :update, :destroy]
  before_action :set_member, only: [:show, :update, :destroy]

  def show
    if is_a_group_member?
      render_ok @member.user
    end
    permissions_error
  end

  def index
    if is_current_user_member?
      render_ok @group.members
    end
    permissions_error
  end

  def create
    if is_group_admin?
      member = Member.new({group_id:@group.id}.merge member_params)
      save_and_render member
    end
    permissions_error
  end

  def update 
    if is_group_admin? and is_a_group_member?
      @member.update_attributes(alias:params[:alias], admin:params[:admin])
      save_and_render @member
    end
    permissions_error
  end

  def destroy
    if is_group_admin? and is_a_group_member?
      render_ok @member.destroy  
    end
    permissions_error
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

  def member_params
    params.permit(
      :alias,
      :user_id,
      :admin
    )
  end
end
