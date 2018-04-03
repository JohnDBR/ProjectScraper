class LinksController < ApplicationController
  skip_before_action :get_current_user, only: [:open, :destroy, :add_schedules, :schedule]
  before_action :set_link, only: [:open, :destroy, :add_schedules, :schedule]

  def create
    if is_current_user_member
      link = Link.new(group_id:params[:group_id].to_i)
      save_and_render link
    else
      permissions_error
    end
  end

  def open
    set_user_by_token
    if @current_user
      member = Member.where(group_id:@link.group_id, user_id:@current_user.id).first
      if member
        render json: {authorization: "already in"}, status: :unprocessable_entity        
      else
        member = Member.create(alias:params[:alias], group_id:@link.group_id, user_id:@current_user.id, admin:false)
        render json: {link:@link.destroy, member:member}, status: :ok
      end
    elsif @link
      render json: {guest: "Welcome!"}, status: :ok
    else
      permissions_error
    end
  end

  def add_schedules
    if @link
      group = @link.group
      s = ScraperHelper.new
      s.add_schedule_to_storage(group, params)
      s.create_conflict_matrix(group)
      render json: {json: s.conflict_matrix, errors: s.errors}, status: :ok
    else
      permissions_error
    end
  end

  def schedule 
    if @link
      s = ScraperHelper.new
      group = @link.group
      s.create_conflict_matrix(group)
      render json: {json: s.conflict_matrix, errors: s.errors}, status: :ok
    else
      permissions_error
    end
  end

  def destroy
    render_ok @link.destroy
  end

  private 
  def set_link
    @link = Link.where(secret:params[:link]).first
  end

  def is_current_user_member
    return Member.where(group_id:params[:group_id].to_i, user_id:@current_user.id).first
  end
end
