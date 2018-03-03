require_relative '../scraper/classes/scraped'
require_relative '../scraper/classes/scraping_authenticate'
require_relative '../scraper/classes/scraping_pomelo'
require_relative '../scraper/classes/scraping_unespacio'

class ScraperController < ApplicationController
  before_action :initialize_authenticate_scraper
  before_action :initialize_pomelo_scraper, only: [:student_schedule, :conflict_matrix]
  # before_action :initialize_unespacio_scraper, only: []

  def student_schedule
    @sl.login_pomelo?(params[:user], params[:password])
    @sp.student_info()
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
