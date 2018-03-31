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
        Member.create(alias:params[:alias], group_id:@link.group_id, user_id:@current_user.id, admin:false)
        render_ok @link.destroy
      end
    elsif @link
      render json: {guest: "Welcome!"}, status: :ok
    else
      permissions_error
    end
  end

  def add_schedules
    if @link
      sl = ScrapingAuthenticate.new
      sp = ScrapingPomelo.new
      group = @link.group
      if group.storage
        sp.load(group.storage.path)
        group.storage.destroy
      end
      sl.login_pomelo?(params[:user], params[:password])
      result = sp.student_info(true)
      s = Storage.create(path:sp.save(Storage.get_path))
      group.update_attribute(:storage_id, s.id)
      render_ok result
    else
      permissions_error
    end
  end

  def schedule 
    if @link
      s = ScraperHelper.new
      sp = ScrapingPomelo.new
      group = @link.group
      if group.storage
        sp.load(group.storage.path)
        s.join_schedules(sp.conflict_matrix)
      end
      group.members.map do |member| #.map is required to iterate through ActiveRecord::Associations::CollectionProxy element, it is not an array...
        if member.user.storage
          sp.load(member.user.storage.path)
          s.join_schedules(sp.temporal_student.schedule, member.alias)
        else
          s.add_errors(member.alias)
        end
      end
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
