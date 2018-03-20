class GroupsController < ApplicationController
  before_action :set_group, only: [:update, :destroy]

  def index
    render_ok @current_user.groups
  end

  def create
    group = Group.new params[:name]
    save_and_render group
    Member.create(alias:params[:alias], group_id:group.id, user_id:@current_user.id)
  end

  def update 
    @group.update_attribute params[:name] 
    save_and_render @group
  end

  def destroy
    render_ok @group.destroy  
  end

  private 
  def set_group
    @group = Group.find params[:id]
  end
end
