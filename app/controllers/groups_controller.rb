class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :schedule, :add_schedules]

  def index
    render_ok @current_user.groups
  end

  def show
    if @group.user_id == @current_user.id
      render_ok @group
    elsif is_current_user_admin.nil?
      render_ok @group
    end
  end

  def create
    group = Group.new(name:params[:name])
    save_and_render group
    member_alias = ""
    member_alias = params[:alias] if params[:alias]
    Member.create(alias:member_alias, group_id:group.id, user_id:@current_user.id, admin:true)
  end

  def update 
    if is_group_admin(@group.id)
      @group.update_attribute(:name, params[:name])
      save_and_render @group
    else
      permissions_error
    end
  end

  def destroy
    if is_group_admin(@group.id)
      render_ok @group.destroy      
    else 
      permissions_error 
    end
  end

  def schedule 
    if is_current_user_member(params[:id])
      s = ScraperHelper.new
      s.create_conflict_matrix(@group)
      render json: {json: s.conflict_matrix, errors: s.errors}, status: :ok
    else
      permissions_error
    end
  end

  def add_schedules #This method is not going to be used due to Unimatrix requirements! ...
    if is_current_user_member(params[:id])
      s = ScraperHelper.new
      if s.add_schedule_to_storage(@group, params)
        s.create_conflict_matrix(@group)
        render json: {json: s.conflict_matrix, errors: s.errors}, status: :ok
      else
        uninorte_authentication_error
      end
    else
      permissions_error
    end
  end

  private 
  def set_group
    @group = @current_user.groups.find params[:id]
  end

  # def is_current_user_member
  #   return Member.where(group_id:params[:id].to_i, user_id:@current_user.id).first
  # end

  # def is_group_admin?
  #   return Member.where(group_id:@group.id, user_id:@current_user.id).first.admin
  # end
end
