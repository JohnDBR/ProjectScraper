class GroupsController < ApplicationController
  before_action :set_group, only: [:update, :destroy, :create_link]
  skip_before_action :get_current_user, only: :open_link

  def index
    render_ok @current_user.groups
  end

  def create
    group = Group.new(name:params[:name])
    save_and_render group
    Member.create(alias:params[:alias], group_id:group.id, user_id:@current_user.id, admin:true)
  end

  def update 
    if is_group_admin?
      @group.update_attribute(:name, params[:name])
      save_and_render @group
    else
      permissions_error
    end
  end

  def destroy
    if is_group_admin?
      render_ok @group.destroy      
    else 
      permissions_error 
    end
  end

  def create_link
    if is_current_user_member
      link = Link.create(group_id:params[:id].to_i)
      render_ok link
    else
      permissions_error
    end
  end

  def open_link
    set_user_by_token
    link = Link.where(secret:params[:link]).first
    if @current_user
      Member.create(alias:params[:alias], group_id:link.group_id, user_id:@current_user.id, admin:false)
      render_ok link.destroy
    elsif link
      render json: {message: "Welcome!"}, status: :guest_access
    else
      permissions_error
    end
  end

  def destroy_link
    render_ok Link.where(secret:params[:link]).first.destroy
  end

  private 
  def set_group
    @group = @current_user.groups.find params[:id]
  end

  def is_current_user_member
    return Member.where(group_id:params[:group_id].to_i, user_id:@current_user.id).first
  end

  def is_group_admin?
    return Member.where(group_id:@group.id, user_id:@current_user.id).first.admin
  end
end
