class Room

  attr_reader :name, :code, :capacity 
  attr_accessor :schedule

  def initialize(name, code, capacity)
    #name: a string with the name of the room
    @name = name
    #code: a string with the code assigned by unespacio for the room 
    @code = code
    #capacity: a Integer that represents the maximun number of stuudents in the room
    @capacity = capacity
    #schedule: a hash of arrays: keys are the dates and the value are arrays of strings that simbolize the hours of reservations from that date
    @schedule = {}
  end
  
  #receive: a string with the format "hour:minutes AM/PM - hour:minutes AM/PM - NorthDayConvention" and it stores in the schedule with a nicer format
  def add_to_schedule_time(date, string)
    int = Integer(date.wday)
    string = complete_format(string)
    @schedule["#{date.to_s} - #{what_day(int)}"] ||= Array.new
    @schedule["#{date.to_s} - #{what_day(int)}"].push "#{string}"    
  end
  
  #receive: a string with the format "12hour:30 AM/PM"
  #return: a string with the format "24hour:30-24hour:30" with range of :30 minutes
  def complete_format(string)
    parts = string.split(":")
    if !string.include?("AM") then parts[0] = set_24hour(parts[0].split(":").first) end 
    parts[1] = parts[1].split.first
    string = "#{parts[0]}:#{parts[1]}"
    if parts[1].eql?("30") 
      parts[0] = (Integer(parts[0]) + 1 % 12).to_s
      parts[1] = "00"
    else
      parts[1] = "30"
    end
    return "#{string}-#{parts[0]}:#{parts[1]}"
  end
  
  #receive: a string with the format "hour:30 AM/PM - hour:30 AM/PM - NorthDayConvention" and it stores in the schedule with a nicer format
  def add_to_schedule(date, int, string)
    string = correct_format(string)
    @schedule["#{date} - #{what_day(int)}"] ||= Array.new
    @schedule["#{date} - #{what_day(int)}"].push "#{string}"    
  end

  #receive: a string with the format "12hour:30 AM/PM - 12hour:30 AM/PM"
  #return: a string with the format "24hour:30-24hour:30"
  def correct_format(string)
    parts = string.split("-")
    if parts[0].include?("AM") then parts[0] = "#{set_24hour(parts[0].split(":").first, false)}:30" else parts[0] = "#{set_24hour(parts[0].split(":").first)}:30" end 
    if parts[1].include?("AM") then parts[1] = "#{set_24hour(parts[1].split(":").first, false)}:30" else parts[1] = "#{set_24hour(parts[1].split(":").first)}:30" end
    return "#{parts[0]}-#{parts[1]}"
  end
  
  #receive: a string with the format "12hour" (whitout the minutes :30)
  #return: a string wiht the format "24hour" (without the minutes :30)
  def set_24hour(string, pm = true)
    int = Integer(string)
    if pm
      if int != 12 then int = int + 12 end
    else
      if int == 12 then int = 0 end
    end
    return "#{int}";
  end

  #receive: a int that represent the days of the week
  #return: the string of the real day of the week
  def what_day(int)
    days = {
      0 => "Sunday",
      1 => "Monday", 
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday"
    }
    return days[int]
  end
end