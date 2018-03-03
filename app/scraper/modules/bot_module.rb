require 'watir'
require 'webdrivers'
require 'mechanize'

module BotModule
  
  #entity: a Mechanize object (the bot)
  @@entity = Mechanize.new{|x| x.user_agent_alias = 'Linux Firefox'}
  
  #browser: a Watir object emulating a browser with phantomjs 
  # caps = Selenium::WebDriver::Remote::Capabilities.chrome("desiredCapabilities" => {"takesScreenshot" => true}, "chromeOptions" => {"binary" => "/usr/local/bin/chromedriver"})
  # @@browser = Watir::Browser.new :chrome, desired_capabilities: caps, :switches => %w[--no-sandbox --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu --headless]
  # @@browser.driver.manage.timeouts.implicit_wait = 100 # seconds
  @@browser = Watir::Browser.new :chrome, headless: true

  #@@browser.driver.manage.window.maximize
  #args = %w{--ignore-ssl-errors=true}
  #@@browser = Watir::Browser.new(:phantomjs, :args => args)   
  #preparing the size of the browser to not get troubles...
  #@@browser.driver.manage.window.resize_to(1280, 1024)
  
  #links: a hash with the links that we're going to use
  @@links = {
    login_pomelo: 'https://pomelo.uninorte.edu.co/pls/prod/twbkwbis.P_WWWLogin',
    schedule: 'https://pomelo.uninorte.edu.co/pls/prod/bwskfshd.P_CrseSchdDetl',
    unespacio: 'http://guaymaro.uninorte.edu.co/unespacio/index.php',
    rooms: 'http://guaymaro.uninorte.edu.co/unespacio/index.php?p=BookRoom&r=1',
    find_rooms: 'http://guaymaro.uninorte.edu.co/unespacio/index.php?p=FindRoomSS&r=1',
    room_detail_part: "http://guaymaro.uninorte.edu.co/unespacio/index.php?p=RoomDetails&rid=",
    bookings: 'http://guaymaro.uninorte.edu.co/unespacio/index.php?p=MyBookings&r=1'
  }
  
  #return: bot
  def self.entity
    return @@entity
  end

  #return: browser
  def self.browser
    return @@browser
  end
  
  #return: links hash
  def self.links
    return @@links
  end
  
  #receive: link of the page
  #return: Nokogiri object of the HTML from the page
  def self.get_nokogiri_html(url)
    return @@entity.get(url).parser
  end

  #return: Nokogiri objecto of the HTML from the page
  def self.get_nokogiri_html_browser()
    return Nokogiri::HTML browser.html
  end
  
  #receive: link of the page
  #return: the page in the Mechanize object
  def self.get_page(url)
    return @@entity.get(url)
  end
  
  #receive: link of the page
  ##return: the page on the browser
  def self.browser_get_page(url)
    @@browser.goto(url)
    @@browser.window.maximize
    # Get the actual page dimensions using javascript
    #width  = @@browser.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    #height = @@browser.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")

    # Add some pixels on top of the calculated dimensions for good
    # measure to make the scroll bars disappear
    #@@browser.driver.manage.window.resize_to(width+100, height+100)
    #return @@browser.goto(url)
  end

  #creates a new object Mechanize to start over
  def self.reset_entity
    @@entity.reset
  end

  #creates a new object Watir to start over
  def self.clean_browser
    @@browser = Watir::Browser.new :chrome, headless: true
  end

  #refresh the watir browser
  def self.refresh_browser
    @@browser.refresh
  end
end