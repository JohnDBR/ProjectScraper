class GroupsController < ApplicationController
  before_action :set_group, only: [:update, :destroy]

  def index
    render_ok @current_user.groups
  end

  def create
    group = Group.new(name:params[:name])
    save_and_render group
    Member.create(alias:params[:alias], group_id:group.id, user_id:@current_user.id, admin:params[:admin])
  end

  def update 
    if is_group_admin?
      @group.update_attribute(:name, params[:name])
      save_and_render @group
    end
    permissions_error
  end

  def destroy
    if is_group_admin?
      render_ok @group.destroy      
    end 
    permissions_error 
  end

  private 
  def set_group
    @group = @current_user.group.find params[:id]
  end

  def is_group_admin?
    return Member.where(group_id:@group.id, user_id:@current_user.id).admin
  end
end