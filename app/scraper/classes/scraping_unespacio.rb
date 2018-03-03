require_relative '../modules/file_module'
require_relative '../modules/bot_module'
require_relative 'scraped'
require_relative 'student'
require_relative 'room'
require 'date'

class ScrapingUnespacio < Scraped

  def initialize
    super
    #rooms: an array rooms (class Room)
    ##@@rooms = []    
  end

  def load_rooms
    rooms = FileModule.deserialize("rooms(0)")
    if rooms.nil?
      return false
    else
      @@rooms = rooms
      return true
    end
  end

  def create_rooms
    BotModule.browser_get_page(BotModule.links[:rooms])
    sleep 1
    # BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
    BotModule.browser.element(css: ".ActionBarResultsPerPage").option(value: "50").click
    sleep 1
    htmlNokogiri = BotModule.get_nokogiri_html_browser
    pagesIds = Array.new 
    roomsNames = Array.new
    htmlNokogiri.css(".ClickableRow").each do |row|
      pagesIds.push row.attributes["data-rowid"].value
      roomsNames.push row.css("td")[2].text   
    end  
    #BotModule.browser.div(class: "imgNextArrow").click
    #sleep 1
    #htmlNokogiri = BotModule.get_nokogiri_html_browser
    #htmlNokogiri.css(".ClickableRow").each do |row|
    #  pagesIds.push row.attributes["data-rowid"].value
    #  roomsNames.push row.css("td")[2].text
    #end
    pagesIds.each_with_index do |id, index|
      next if index == 1 or index == 2 or index == 36 or index == 37 #Those rooms can't be reseverd via web
      BotModule.browser_get_page(BotModule.links[:room_detail_part]+id)
      #p browser.element(css: ".pageHeader").text.strip
      capacity = BotModule.browser.element(css: "tr.HTMLTable-AlignTD:nth-child(3) > td:nth-child(2) > span:nth-child(1)").text.strip
      BotModule.refresh_browser
      @@rooms.push(Room.new(roomsNames[index], id, capacity))
      #Fetching the day schedules of the rooms in the actual day...  
      #BotModule.browser.a(href: "#").click
      #BotModule.browser.span(class: "TabCaption", text: "Daily").click
      #reservations = BotModule.browser.divs(class: "calendarBlock")
      #reservations.each do |reservation|
      #  reservation.click
      #  sleep(1)
      #  #p BotModule.browser.element(css: ".BlockContent > p:nth-child(1)").text.strip.split("\n")[2] #ADD TO THE NEW ROOM 
      #  @rooms.last.add_to_schedule(Date.today.to_s, Date.today.wday, BotModule.browser.element(css: ".BlockContent > p:nth-child(1)").text.strip.split("\n")[2])
        #p @rooms.last.schedule
      #end    
    end
    FileModule.serialize(@@rooms, "rooms")
    #pp @rooms
    BotModule.clean_browser
  end  

  def search_room_schedule(room_name, date_s)
    date = Date.parse(date_s)
    BotModule.browser_get_page(BotModule.links[:rooms])
    sleep 1
    BotModule.browser.element(css: ".ActionBarResultsPerPage").option(value: "50").click
    sleep 1
    day_available = true
    room = @@rooms.find {|r| r.name == room_name}
    code = 'tr[data-rowid="' + room.code + '"]'
    BotModule.browser.element(css: code).click
    sleep 1
    BotModule.browser.element(css: "#btnAnyDate").click
    sleep 1
    script_pass_month = "IS.SelfService.AvailabilityCalendar.ScrollTo(3);"
    find_table = false
    begin
      day_available = true
      for i in 0..2
        table = BotModule.browser.element(css: "#availabilityCalendar#{i}")
        header = table.td(class: "dayHeader").text.strip
        if header.include? what_month(date.month) and header.include? date.year.to_s
          find_table = true
          calendar_day = table.div(text: date.day.to_s)
          day_available = calendar_day.parent.attribute_value("class").include? "dayAvailable"
          break if !day_available
          calendar_day.click
          sleep 1
          BotModule.browser.element(css: 'div.listDiv:nth-child(2) > table:nth-child(1) > tbody:nth-child(2)').wait_until_present
          room_schedule = BotModule.browser.element(css: 'div.listDiv:nth-child(2) > table:nth-child(1) > tbody:nth-child(2)')
          room_schedule.trs.each do |tr|
            hour = tr.tds[0].text.strip
            status = tr.tds[1].text.strip
            if !status.empty?
              room.add_to_schedule_time(date, hour)
            end
          end
          break
        end  
      end
      BotModule.browser.execute_script(script_pass_month) unless find_table
      sleep 1
    end until find_table
    (6..12).each { |i| room.add_to_schedule_time(date, "#{i}:00 AM") } if !day_available
    (1..8).each { |i| room.add_to_schedule_time(date, "#{i}:00 PM") } if !day_available
    BotModule.clean_browser
    return room.schedule["#{date.to_s} - #{what_day(Integer(date.wday))}"]
  end

  def search_all_room_schedules(date_s, capacity = -1)
    date = Date.parse(date_s)
    BotModule.browser_get_page(BotModule.links[:rooms])
    sleep 1
    BotModule.browser.div(class: "imgBackArrow").click
    sleep 1
    BotModule.browser.element(css: ".ActionBarResultsPerPage").option(value: "50").click
    sleep 1
    day_available = true
    @@rooms.each_with_index do |room, index|
      #p "ENTRE!"
      #p index
      if capacity != -1 then next if Integer(room.capacity) != capacity end 
      code = 'tr[data-rowid="' + room.code + '"]'
      BotModule.browser.element(css: code).wait_until_present
      BotModule.browser.element(css: code).click
      sleep 1
      BotModule.browser.element(css: "#btnAnyDate").click
      sleep 1
      #script_table_order = "arguments[0].style.float = 'initial';"
      script_pass_month = "IS.SelfService.AvailabilityCalendar.ScrollTo(3);"
      #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
      find_table = false
      begin
        day_available = true
        for i in 0..2
          BotModule.browser.element(css: "#availabilityCalendar#{i}").wait_until_present
          table = BotModule.browser.element(css: "#availabilityCalendar#{i}")
          #3.times do 
          #  table.visible? ? BotModule.browser.execute_script(script_table_order, table) : break
          #end
          #BotModule.browser.execute_script(script_table_order, table)
          #sleep 1
          header = table.td(class: "dayHeader").text.strip
          if header.include? what_month(date.month) and header.include? date.year.to_s
            find_table = true
            #p "Sacare su horario!"
            calendar_day = table.div(text: date.day.to_s)
            day_available = calendar_day.parent.attribute_value("class").include? "dayAvailable"
            break if !day_available
            calendar_day.click
            sleep 1
            BotModule.browser.element(css: 'div.listDiv:nth-child(2) > table:nth-child(1) > tbody:nth-child(2)').wait_until_present
            room_schedule = BotModule.browser.element(css: 'div.listDiv:nth-child(2) > table:nth-child(1) > tbody:nth-child(2)')
            room_schedule.trs.each do |tr|
              hour = tr.tds[0].text.strip
              status = tr.tds[1].text.strip
              #p status 
              if !status.empty?
                @@rooms[index].add_to_schedule_time(date, hour)
              end
            end
            break
          end  
        end
        BotModule.browser.execute_script(script_pass_month) unless find_table
        sleep 1
      end until find_table
      break if !day_available
      #Fetching the schedules with the calendar link... (Out of date)
      #BotModule.browser_get_page(BotModule.links[:room_detail_part]+room.code)
      #BotModule.refresh_browser
      #BotModule.browser.a(href: "#").click
      #BotModule.browser.span(class: "TabCaption", text: "Daily").click
      #pageDay = BotModule.browser.element(css: "#td0").text.strip     
      #i = 0
      #while i < Integer(day) do
      #  sleep(1)
      #  BotModule.browser.element(css: "a.calendarNavLink:nth-child(3)").click
      #  i = i + 1
      #end
      #p BotModule.browser.element(css: "#td0").text.strip
      #reservations = BotModule.browser.divs(class: "calendarBlock")
      #reservations.each do |reservation|
      #  reservation.click
      #  sleep(1)
      #  @@rooms.last.add_to_schedule((Date.today + Integer(day)).to_s, (Date.today + Integer(day)).wday, BotModule.browser.element(css: ".BlockContent > p:nth-child(1)").text.strip.split("\n")[2])
      #end
    end
    @@rooms.each_with_index { |room, index| (6..12).each { |i| rooms[index].add_to_schedule_time(date, "#{i}:00 AM") } } if !day_available
    @@rooms.each_with_index { |room, index| (1..8).each { |i| rooms[index].add_to_schedule_time(date, "#{i}:00 PM") } } if !day_available
    BotModule.clean_browser    
    #pp @rooms
    return rooms_names
  end

  def search_room_to_conflict_matrix(date_s, range, logger)
    logger.login_unespacio?(@@students[0].username, @@students[0].password)
    date = Date.parse(date_s)
    parts = range.split("-")
    r = parts[0].split()
    r1 = parts[1].split()
    range = "#{r[0]} #{r[1].upcase}-#{r1[0]} #{r1[1].upcase}"
    parts = range.split("-")
    difference = dif = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
    diff_parts = difference.to_s.split(".")
    if diff_parts[0].length == 1 then diff_parts[0] = "0#{diff_parts[0]}" end
    if diff_parts[1].eql?("5") then difference = "#{diff_parts[0]}:30" else difference = "#{diff_parts[0]}:00" end
    BotModule.browser_get_page(BotModule.links[:find_rooms])
    sleep 1
    if dif >= 2
      BotModule.browser.element(css: "#cboDuration").option(text: "02:00").click
    else
      BotModule.browser.element(css: "#cboDuration").option(text: "#{difference}").click
    end
    BotModule.browser.element(css: "#cboStartTime").option(text: parts[0]).click
    BotModule.browser.element(css: "#cboEndTime").option(text: parts[1]).click
    BotModule.browser.element(css: "#btnAnyDate").click
    sleep 1
    #script_table_order = "arguments[0].style.float = 'initial';"
    script_pass_month = "IS.SelfService.AvailabilityCalendar.ScrollTo(3);"
    day_available = true
    find_table = false
    begin
      for i in 0..2
        BotModule.browser.screenshot.save("./screens/phantomjs_screen.png")
        BotModule.browser.element(css: "#availabilityCalendar#{i}").wait_until_present
        table = BotModule.browser.element(css: "#availabilityCalendar#{i}")
        header = table.td(class: "dayHeader").text.strip
        if header.include? what_month(date.month) and header.include? date.year.to_s
          find_table = true
          calendar_day = table.div(text: date.day.to_s)
          day_available = calendar_day.parent.attribute_value("class").include? "dayAvailable"
          break if !day_available
          calendar_day.click
          sleep 1
          cont = 0
          BotModule.browser.element(css: "#rooms").wait_until_present
          sleep 1
          BotModule.browser.element(css: "#rooms > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > h2:nth-child(1)").click
          sleep 1
          ####search_tables = BotModule.browser.element(css: "#rooms")
          result_rooms = []
          iterate = BotModule.browser.element(css: "#rooms").divs(class: "PageSection initialized")
          frequency = iterate.size
          iterate.each do |table|
            table.element(class: "titleSectionCollapsible").click
            identifier = table.element(class: "titleSectionCollapsible").element(class: "titleSectionLabel").text.strip
            parts = identifier.split()
            hour_detail = parts[0].split(":")
            sleep 1 
            #pp table.element(class: "ActionBarResultsPerPage").text
            table.element(class: "ActionBarResultsPerPage", index:0).option(text: "50").click
            sleep 1
            table.divs[0].divs[0].tables[1].trs.each_with_index do |tr, index|
              if index != 0
               result_rooms.push(tr.tds[2].text)
              end 
            end
          end
          #pp result_rooms
          groups = result_rooms.inject({}) do |hsh, ball|
            #hsh[ball] = 1 if hsh[ball].nil?
            hsh[ball] ||= 0
            hsh[ball] = hsh[ball] + 1
            hsh
          end 
          #pp groups
          available_rooms = []
          groups.each do |key, value|
            if value == frequency
              available_rooms.push(key)
            end
          end
          #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png")
          ##pp available_rooms
          result_rooms = []
          available_rooms.each do |a_room|
            r_capacity = @@rooms.find {|rm| rm.name == a_room}
            result_rooms.push("#{a_room}, Capacity = #{r_capacity.capacity}") 
          end
          BotModule.clean_browser
          #return available_rooms
          return result_rooms
          break
        end  
      end
      BotModule.browser.execute_script(script_pass_month) unless find_table
      sleep 1
    end until find_table
    BotModule.clean_browser
    return nil if !day_available
    #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
  end

  def search_room_to_reserve(date_s, range)
    date = Date.parse(date_s)
    parts = range.split("-")
    r = parts[0].split()
    r1 = parts[1].split()
    range = "#{r[0]} #{r[1].upcase}-#{r1[0]} #{r1[1].upcase}"
    parts = range.split("-")
    difference = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
    diff_parts = difference.to_s.split(".")
    if diff_parts[0].length == 1 then diff_parts[0] = "0#{diff_parts[0]}" end
    if diff_parts[1].eql?("5") then difference = "#{diff_parts[0]}:30" else difference = "#{diff_parts[0]}:00" end
    BotModule.browser_get_page(BotModule.links[:find_rooms])
    sleep 1
    #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
    BotModule.browser.element(css: "#cboDuration").option(text: difference).click
    BotModule.browser.element(css: "#cboStartTime").option(text: parts[0]).click
    BotModule.browser.element(css: "#cboEndTime").option(text: parts[1]).click
    BotModule.browser.element(css: "#btnAnyDate").click
    sleep 1
    #script_table_order = "arguments[0].style.float = 'initial';"
    script_pass_month = "IS.SelfService.AvailabilityCalendar.ScrollTo(3);"
    day_available = true
    find_table = false
    begin
      for i in 0..2
        BotModule.browser.element(css: "#availabilityCalendar#{i}").wait_until_present
        table = BotModule.browser.element(css: "#availabilityCalendar#{i}")
        header = table.td(class: "dayHeader").text.strip
        if header.include? what_month(date.month) and header.include? date.year.to_s
          find_table = true
          calendar_day = table.div(text: date.day.to_s)
          day_available = calendar_day.parent.attribute_value("class").include? "dayAvailable"
          break if !day_available
          calendar_day.click
          sleep 1
          BotModule.browser.element(class: "ActionBarResultsPerPage", index:0).option(text: "50").click
          sleep 1
          ids = []
          BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)").trs.each { |tr| ids.push(tr.attribute('data-rowid')) }
          result_rooms = []
          ids.each do |id|
            room = @@rooms.find {|room| room.code == id}
            result_rooms.push("#{room.name}, Capacity = #{room.capacity}") 
          end
          return result_rooms
          break
        end  
      end
      BotModule.browser.execute_script(script_pass_month) unless find_table
      sleep 1
    end until find_table
    return nil if !day_available
    #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
  end

  def reserve_room(room)
    if !room.empty?
      room = room.split(",")[0]
      id = @@rooms.find {|r| r.name == room }.code
      code = 'tr[data-rowid="' + id + '"]'
      BotModule.browser.element(css: code).click
      BotModule.browser.element(css: "input.MessageBoxButton:nth-child(1)").click
      sleep 1
      BotModule.browser.element(css: "#btnConfirm").click
      # BotModule.browser.element(css: "#btnConfirm").click ##Shouldn't be
      BotModule.browser.element(css: "input.MessageBoxButton:nth-child(1)").click
      BotModule.clean_browser
      return true
    else
      BotModule.clean_browser
      return false
    end
  end

  def reserve_conflict_matrix(room, date_s, intervals, logger)
    if intervals.any? and !room.empty?
      date = Date.parse(date_s)
      script_pass_month = "IS.SelfService.AvailabilityCalendar.ScrollTo(3);"
      BotModule.browser.screenshot.save("./screens/phantomjs_screen.png")
      intervals.each_with_index do |interval, index|
        logger.login_unespacio?(@@students[index].username, @@students[index].password)
        parts = interval.split("-")
        r = parts[0].split()
        r1 = parts[1].split()
        interval = "#{r[0]} #{r[1].upcase}-#{r1[0]} #{r1[1].upcase}"
        parts = interval.split("-")
        difference = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
        diff_parts = difference.to_s.split(".")
        if diff_parts[0].length == 1 then diff_parts[0] = "0#{diff_parts[0]}" end
        if diff_parts[1].eql?("5") then difference = "#{diff_parts[0]}:30" else difference = "#{diff_parts[0]}:00" end
        BotModule.browser_get_page(BotModule.links[:find_rooms])
        sleep 1
        BotModule.browser.element(css: "#cboDuration").option(text: difference).click
        BotModule.browser.element(css: "#cboStartTime").option(text: parts[0]).click
        BotModule.browser.element(css: "#cboEndTime").option(text: parts[1]).click
        BotModule.browser.element(css: "#btnAnyDate").click
        sleep 1
        day_available = true
        find_table = false
        begin
          for i in 0..2
            BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
            BotModule.browser.element(css: "#availabilityCalendar#{i}").wait_until_present
            table = BotModule.browser.element(css: "#availabilityCalendar#{i}")
            header = table.td(class: "dayHeader").text.strip
            if header.include? what_month(date.month) and header.include? date.year.to_s
              find_table = true
              calendar_day = table.div(text: date.day.to_s)
              day_available = calendar_day.parent.attribute_value("class").include? "dayAvailable"
              break if !day_available
              calendar_day.click
              sleep 1
              BotModule.browser.element(class: "ActionBarResultsPerPage", index:0).option(text: "50").click
              sleep 1
              BotModule.browser.screenshot.save("./screens/phantomjs_screen.png")
              room = room.split(",")[0]
              id = @@rooms.find {|r| r.name == room }.code
              code = 'tr[data-rowid="' + id + '"]'
              BotModule.browser.element(css: code).click
              BotModule.browser.element(css: "input.MessageBoxButton:nth-child(1)").click
              sleep 1
              BotModule.browser.element(css: "#btnConfirm").click
              # BotModule.browser.element(css: "#btnConfirm").click ##Shouldn't be
              BotModule.browser.element(css: "input.MessageBoxButton:nth-child(1)").click
              BotModule.clean_browser
              break
            end  
          end
          BotModule.browser.execute_script(script_pass_month) unless find_table
          sleep 1
        end until find_table
        return false if !day_available
      end
      pp "entre"
      return true
    else
      return false;
    end
  end

  def search_bookings()
    BotModule.browser_get_page(BotModule.links[:bookings])
    sleep 1
    table = BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)")
    if !table.trs[0].text.eql?("No results found.")
      result_rooms = []
      for i in 0...table.trs.size
        table = BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)")
        next unless table.trs[i].tds[0].imgs[0].attribute("title").include?("Approved")
        parts = "#{BotModule.browser.element(css: "tr.ClickableRow:nth-child(1) > td:nth-child(2) > div:nth-child(1)").text}, #{BotModule.browser.element(css: "tr.ClickableRow:nth-child(1) > td:nth-child(3)").text}"
        table.trs[i].click 
        sleep 1
        #BotModule.browser.screenshot.save("./screens/phantomjs_screen.png") 
        BotModule.browser.element(css: "table.SubSectionTable:nth-child(4) > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(1) > div:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(1) > span:nth-child(1) > a:nth-child(1)").click
        sleep 1
        result_rooms.push("#{BotModule.browser.element(css: "table.SubSectionTable:nth-child(1) > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(1) > div:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(4)").text} = #{parts}") 
        BotModule.browser_get_page(BotModule.links[:bookings])
        sleep 1
      end
      return result_rooms if result_rooms.any?
    end
    return nil
  end

  def cancel_booking(position)
    if !position.nil?
      BotModule.browser_get_page(BotModule.links[:bookings])
      sleep 1
      cont = -1
      table = BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)")
      for i in 0...table.trs.size
        table = BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)")
        next unless table.trs[i].tds[0].imgs[0].attribute("title").include?("Approved")       
        cont = cont + 1
        next if cont != position
        BotModule.browser.element(css: ".listDiv > table:nth-child(1) > tbody:nth-child(2)").trs[i].click 
        sleep 1
        BotModule.browser.element(css: "#btnCancel").click
        BotModule.browser.element(css: "input.MessageBoxButton:nth-child(1)").click
        BotModule.browser_get_page(BotModule.links[:bookings])
        sleep 1
      end
      BotModule.clean_browser
      return true
    else
      BotModule.clean_browser
      return false
    end
  end
    
  ##def what_month_spanish(number)
  ##  number = number.to_s
  ##  months = {
  ##    "1" => "Enero", 
  ##    "2" => "Febrero",
  ##    "3" => "Marzo", 
  ##    "4" => "Abril", 
  ##    "5" => "Mayo", 
  ##    "6" => "Junio", 
  ##    "7" => "Julio", 
  ##    "8" => "Agosto", 
  ##    "9" => "Septiembre", 
  ##    "10" => "Octubre", 
  ##    "11" => "Noviembre", 
  ##    "12" => "Diciembre"
  ##  }
  ##  return months[number] 
  ##end

  ##def what_month(number)
  ##  number = number.to_s
  ##  months = {
  ##    "1" => "January", 
  ##    "2" => "February",
  ##    "3" => "March", 
  ##    "4" => "April", 
  ##    "5" => "May", 
  ##    "6" => "June", 
  ##    "7" => "July", 
  ##    "8" => "August", 
  ##    "9" => "September", 
  ##    "10" => "October", 
  ##    "11" => "November", 
  ##    "12" => "December"
  ##  }
  ##  return months[number] 
  ##end
end