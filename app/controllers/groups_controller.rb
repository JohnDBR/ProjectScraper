class GroupsController < ApplicationController
  before_action :set_group, only: [:update, :destroy, :add_schedules]

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

  def schedule 
    # if @current_user.storage
    #   sp = ScrapingPomelo.new
    #   sp.load(@current_user.storage.path)
    #   render_ok sp.temporal_student.schedule
    # else
    #   render json: {message: "the schedule isn't fetched"}, status: :unprocessable_entity 
    # end
  end

  def add_schedules
    if is_current_user_member
      sl = ScrapingAuthenticate.new
      sp = ScrapingPomelo.new
      if @group.storage
        sp.load(@group.storage.path)
        @group.storage.destroy
      end
      sl.login_pomelo?(params[:user], params[:password])
      result = sp.student_info(true)
      s = Storage.create(path:sp.save(Storage.get_path))
      @group.update_attribute(:storage_id, s.id)
      render_ok result
    else
      permissions_error
    end
  end

  private 
  def set_group
    @group = @current_user.groups.find params[:id]
  end

  def is_current_user_member
    return Member.where(group_id:params[:id].to_i, user_id:@current_user.id).first
  end

  def is_group_admin?
    return Member.where(group_id:@group.id, user_id:@current_user.id).first.admin
  end
end
