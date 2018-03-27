class ScraperController < ApplicationController
  before_action :initialize_authenticate_scraper
  before_action :initialize_pomelo_scraper, only: [:student_schedule, :conflict_matrix]
  # before_action :initialize_unespacio_scraper, only: []

  def student_schedule
    @sl.login_pomelo?(params[:user], params[:password])
    result = @sp.student_info()
    @current_user.storage = Storage.new(path:@sp.save(Storage.get_path))
    render_ok result
  end

  def conflict_matrix
    if @current_user.storage
      @sp.load(@current_user.storage.path)
      @current_user.storage.destroy
    end
    @sl.login_pomelo?(params[:user], params[:password])
    result = @sp.student_info(true)
    @current_user.storage = Storage.new(path:@sp.save(Storage.get_path))
    render_ok result
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
end
