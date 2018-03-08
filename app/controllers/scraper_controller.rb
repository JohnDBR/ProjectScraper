class ScraperController < ApplicationController
  skip_before_action :get_current_user 
  before_action :initialize_authenticate_scraper
  before_action :initialize_pomelo_scraper, only: [:student_schedule, :conflict_matrix]
  # before_action :initialize_unespacio_scraper, only: []

  def student_schedule
    # pp "start"
    # @sl = ScrapingAuthenticate.new
    # @sp = ScrapingPomelo.new
    # pp "init"
    @sl.login_pomelo?(params[:user], params[:password])
    render_ok @sp.student_info()
  end

  def conflict_matrix
    @sl.login_pomelo?(params[:user], params[:password])
    @sp.student_info(true)
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
