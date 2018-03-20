class MembersController < ApplicationController
  before_action :set_group, only: [:index, :create]
  before_action :set_member, only: [:update, :destroy]

  def index
    render_ok @group.members
  end

  def create
    member = Member.create(alias:params[:alias], group_id:@group.id, user_id:@current_user.id)
    save_and_render member
  end

  def update 
    @member.update_attribute params[:alias] 
    save_and_render @member
  end

  def destroy
    render_ok @member.destroy  
  end

  private 
  def set_group
    @group = Group.find params[:group_id]
  end

  def set_member
    @member = Member.find params[:id]
  end
end
