require_relative '../modules/bot_module'
require_relative 'scraped'

class ScrapingAuthenticate < Scraped

  def initialize
    super
  end

  #receive: username and password of the student to make the login (scraping the page) on pomelo
  #return: a boolean that is true if login was successful
  def login_pomelo?(user, password) 
    page = BotModule.get_page(BotModule.links[:login_pomelo])
    form = page.forms[0]
    form.sid = user
    form.PIN = password
    document = form.submit.parser.css(".plaintable")
    login_status = document.size == 0
    if login_status
      p "Entre!"
      page = BotModule.get_page('https://pomelo.uninorte.edu.co/pls/prod/bwckcapp.P_DispCurrent') #Empanadita con queso...
      code_name = page.parser.css('.staticheaders').text.split("\n")[1].split(' ')
      name = code_name[1..-1].join(' ') 
      @@temporal_student = Student.new(name, code_name[0], user)#, password)        
    end
    return login_status
  end

  #receive: username and password of the student to make the login (scraping the page) on guaymaro
  #return: a boolean that is true if login was successful
  def login_unespacio?(user, password) 
    BotModule.browser_get_page(BotModule.links[:unespacio])
    BotModule.browser.li(class: "userBarButton ", index:1).click
    BotModule.browser.text_field(name: 'txtUsername').set(user)
    BotModule.browser.input(name: 'txtPassword').send_keys(password)
    BotModule.browser.input(value: 'Log in').click
    BotModule.refresh_browser
    return !BotModule.browser.span(id: "spanLogin").exists?
  end
end