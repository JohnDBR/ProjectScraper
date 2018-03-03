class Student
  
  attr_reader :name, :code, :username, :password
  attr_accessor :schedule
  
  def initialize(name, code, username, password)
    #username: a string with the username of uninorte domains
    @username = username
    #password: a string with the password of uninorte domains
    @password = password
    #name: a string with the name of the student
    @name = name
    #code: a string with the university code of the student
    @code = code
    #schedule: a hash of arrays: keys are the days of the week and the value are arrays of strings that simbolize the hours of class from that day
    @schedule = {
      "Monday"    => {},
      "Tuesday"   => {},
      "Wednesday" => {},
      "Thursday"  => {},
      "Friday"    => {},
      "Saturday"  => {},
      "Sunday"    => {}
      } 
    fill_schedule()
  end
  
  #This method put the hours of the day in the schedule 
  def fill_schedule
    @schedule.each do |key,value|
     (6..20).each { |n| @schedule[key]["#{n}:30 - #{n+1}:30"] = "" }
    end
   end
  
  #receive: a string whit the format "hour:30 AM/PM - hour:30 AM/PM - NorthDayConvention" and it stores in the schedule with a nicer format
  def add_to_schedule(string)
    string = correct_format(string)
    parts = string.split("-")
    hour1 = Integer(parts[0].split(":")[0])
    hour2 = Integer(parts[1].split(":")[0])
    if hour2 == hour1 + 1
      @schedule[parts[2]]["#{parts[0]} - #{parts[1]}"] = "1" #schedule[parts[2]].push("#{parts[0]}-#{parts[1]}")
    else 
      while hour1 != hour2
        @schedule[parts[2]]["#{hour1}:30 - #{hour1+1}:30"] = "1"
        hour1 = hour1+1
      end
    end
    return parts
  end
  
  #receive: a string whit the format "12hour:30 AM/PM - 12hour:30 AM/PM - NorthDayConvention"
  #return: a string whit the format "24hour:30-24hour:30-Day"
  def correct_format(string)
    parts = string.split("-")
    if parts[0].include?("AM") then parts[0] = "#{set_24hour(parts[0].split(":").first, false)}:30" else parts[0] = "#{set_24hour(parts[0].split(":").first)}:30" end 
    if parts[1].include?("AM") then parts[1] = "#{set_24hour(parts[1].split(":").first, false)}:30" else parts[1] = "#{set_24hour(parts[1].split(":").first)}:30" end
    parts[2] = what_day(parts[2])
    return "#{parts[0]}-#{parts[1]}-#{parts[2]}"
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
  
  #receive: a string whit the NorthDayConvention
  #return: the string of the real day
  def what_day(string)
    if  string.include?("L")
      return "Monday"
    elsif string.include?("M")
      return "Tuesday"
    elsif string.include?("I")
      return "Wednesday"
    elsif string.include?("J")
      return "Thursday"
    elsif string.include?("V")
      return "Friday"
    elsif string.include?("S")
      return "Saturday"
    elsif string.include?("D")
      return "Sunday"
    end
    return "NONE"
  end
end