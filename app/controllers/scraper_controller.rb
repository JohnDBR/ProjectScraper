class ScraperController < ApplicationController
  before_action :initialize_authenticate_scraper
  before_action :initialize_pomelo_scraper, only: [:student_schedule, :conflict_matrix, :add_schedules]
  # before_action :initialize_unespacio_scraper, only: []
  before_action :set_group, only: [:add_schedules]

  def student_schedule
    @current_user.storage.destroy if @current_user.storage
    @sl.login_pomelo?(params[:user], params[:password])
    result = @sp.student_info()
    s = Storage.create(path:@sp.save(Storage.get_path))
    @current_user.update_attributes(storage_id:s.id, full_name:@sp.temporal_student.name)
    render json: {schedule:result, user:@current_user}, status: :ok
  end

  def conflict_matrix
    # if @current_user.storage
    #   @sp.load(@current_user.storage.path)
    #   @current_user.storage.destroy
    # end
    # @sl.login_pomelo?(params[:user], params[:password])
    # result = @sp.student_info(true)
    # @current_user.storage = Storage.create(path:@sp.save(Storage.get_path))
    # render_ok result
  end

  private 
  def initialize_authenticate_scraper
    @sl = ScrapingAuthenticate.new
  end

  def initialize_pomelo_scraper
    @sp = ScrapingPomelo.new
  end

  def initialize_unespacio_scraper
    @su = ScrapingUnespacio.new
  end

  def set_group
    @group = @current_user.groups.find params[:group_id]
  end
end
