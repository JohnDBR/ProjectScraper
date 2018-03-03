require_relative 'validation_module'
require_relative '../classes/scraping_authenticate'
require 'io/console'

module ConsoleViewModule
  
  #login: makes the login in pomelo uninorte
  #receive: a scraper (class Scraping) to do the login
  #return: a boolean, true is the login was successful
  def self.login(scraper, domain)
    begin 
      print "\nUsername: "
      user = gets.chomp
      print "Password: "
      password = STDIN.noecho(&:gets).chomp
      print "***\n"
      #puts "#{user} y #{password}"
      if domain.eql?("pomelo") 
        status = scraper.login_pomelo?(user, password)
      elsif domain.eql?("unespacio")
        status = scraper.login_unespacio?(user, password)
      else
        puts "there is no domain!\n"
      end 
      puts "login error!\n" unless status 
    end until status
  end
  
  #receive: a string with the message or title of what we are going to select in the menu, and more strings (the options of the menu) if we pass an array these array will be the options of the menu   
  #return: a integer of with the user selection
  def self.menu(message, *options)
    if options.any?
      begin
        puts "\n#{message}\n"
        options.each { |option| if option.instance_of?(Array) then options.push(option) end }
        options.each_with_index do |option, i|
          puts "#{i + 1}- #{option}"
        end
        puts "0-  Salir"
        print "Opcion: "
        selected_option = gets.chomp
        valid_option = ValidationModule.validate_int_range(selected_option, 0, options.length)
        puts "Opcion invalida!" unless valid_option
      end until valid_option
      return Integer(selected_option)
    else
      raise "Menu error!"
    end
  end

  #receive: a string with the message or title of what we are going to select in the menu, and more strings (the options of the menu) if we pass an array these array will be the options of the menu   
  #return: a integer of with the user selection
  def self.menu_from_0(message, *options)
    if options.any?
      begin
        puts "\n#{message}\n"
        n_options = []
        options.each { |option| if option.instance_of?(Array) then option.each { |o| n_options.push(o)} else n_options.push(option) end }
        options = n_options
        options.each_with_index do |option, i|
          puts "#{i}- #{option}"
        end
        print "Opcion: "
        selected_option = gets.chomp
        valid_option = ValidationModule.validate_int_range(selected_option, 0, options.length)
        puts "Opcion invalida!" unless valid_option
      end until valid_option
      return Integer(selected_option)
    else
      return nil
      #raise "Menu error!"
    end
  end

  #receive: a string with the message or title of what we are going to select in the menu, and more strings (the options of the menu) if we pass an array these array will be the options of the menu   
  #return: a string with the message that the user selects
  def self.message_from_0(message, *options)
    if options.any?
      begin
        puts "\n#{message}\n"
        n_options = []
        options.each { |option| if option.instance_of?(Array) then option.each { |o| n_options.push(o)} else n_options.push(option) end }
        options = n_options
        options.each_with_index do |option, i|
          puts "#{i}- #{option}"
        end
        print "Opcion: "
        selected_option = gets.chomp
        valid_option = ValidationModule.validate_int_range(selected_option, 0, options.length)
        puts "Opcion invalida!" unless valid_option
      end until valid_option
      return options[Integer(selected_option)]
    else
      return nil
      #raise "Menu error!"
    end
  end
   
  #receive: a string with the message    
  #return: a Integer with the user prompt
  def self.get_int(message)
    begin 
      print "\n#{message}"
      string = gets.chomp
      valid_int = ValidationModule.validate_int(string)
      puts "Int invalido!" unless valid_int
      return Integer(string) if valid_int
    end until validt_int
  end

  #receive: a string with the message, the first limit of the range and the last limit 
  #return: a Integer in a range with the user prompt
  def self.get_range_int(message, firstLimit, lastLimit)
    begin 
      print "\n#{message}"
      string = gets.chomp
      valid_int = ValidationModule.validate_int(string)
      if valid_int
        number = Integer(string)
        valid_int = number >= Integer(firstLimit) && number <= Integer(lastLimit)
      end
      puts "Int invalido!" unless valid_int
      return Integer(string) if valid_int
    end until valid_int
  end

  #receive: a string with the message to display
  #return: a valid string that represents a date ##should be a object Date parsed of the string given?
  def self.get_date(message)
    begin
      print "\nNota: El formato valido para ingresar la fecha es 'dd-mm-año' o 'dd/mm/año'." 
      print "\n#{message}"
      string = gets.chomp
      valid_date = ValidationModule.validate_future_date(string)
      puts "Fecha invalida!" unless valid_date 
      return string if valid_date
    end until valid_date
  end

  #receive: a string with the message to display 
  #return: the string that represent a range hour
  def self.get_hour_range(message, stg_range = "6:30 AM - 8:30 PM")
    begin
      print "\nNota: El formato valido para ingresar el rango de hora es 'hora:minuto AM/PM - hora:minuto AM/PM'." 
      print "\n#{message}"
      string = gets.chomp
      valid_date = ValidationModule.validate_range_hour_interval(string, "2", stg_range, "0.5")
      puts "Rango de hora invalido!" unless valid_date 
      return string if valid_date
    end until valid_date
  end

  #receive: a string with the message to display 
  #return: the string that represent a range hour
  def self.get_hour_range_between(message, stg_range = "6:30 AM - 8:30 PM")
    begin
      print "\nNota: El formato valido para ingresar el rango de hora es 'hora:minuto AM/PM - hora:minuto AM/PM'." 
      print "\n#{message}"
      string = gets.chomp
      valid_date = ValidationModule.validate_range_hour_between(string, stg_range, "0.5")
      puts "Rango de hora invalido!" unless valid_date 
      return string if valid_date
    end until valid_date
  end
end