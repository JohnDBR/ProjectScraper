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
    if is_current_user_member(params[:group_id])
      render_ok @group.members
    else
      permissions_error
    end
  end

  def create
    if is_group_admin(@group.id)
      # params[:email] ||= ''
      params[:username] ||= ''
      # user = User.find_by(email: params[:email].downcase)
      user = User.find_by(username: params[:username].downcase) #unless user
      if user
        unless Member.where(group_id:params[:group_id].to_i, user_id:user.id).first
          member_alias = ""
          member_alias = params[:alias] if params[:alias]
          member = Member.new(group_id:params[:group_id].to_i, user_id:user.id, alias:member_alias, admin:params[:admin])
          save_and_render member
        else
          render json: {authorization: "already in"}, status: :unprocessable_entity  
        end
      else
        render json: {single_authentication: 'invalid credentials'}, status: :unauthorized 
      end
    else
      permissions_error
    end
  end

  def update 
    member_alias = ""
    member_alias = params[:alias] if params[:alias]
    if is_group_admin(@group.id) and is_a_group_member?
      if !params[:admin].nil?
        @member.update_attributes(alias:member_alias, admin:params[:admin])
      else
        @member.update_attribute(:alias, member_alias)
      end 
      save_and_render @member
    elsif @member.user_id == @current_user.id
      @member.update_attribute(:alias, member_alias)
      save_and_render @member
    else
      permissions_error
    end
  end

  def destroy
    if is_group_admin(@group.id) and is_a_group_member?
      render_ok @member.destroy  
    elsif @member.user_id == @current_user.id
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

  def is_a_group_member?
    return @member.group_id.to_s == params[:group_id]
  end
end
