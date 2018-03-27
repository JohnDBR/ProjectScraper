require_relative '../modules/file_module'
require 'date'
require 'time'

class Scraped 

  #temporal_student: a temporal Student object for quick searchs 
  @@temporal_student = nil
  #rooms: an array rooms (class Room)
  @@rooms = []  
  #students: an array students (class Student)
  @@students = []
  #conflict_matrix: a hash of arrays: keys are the days of the week and the value are arrays of string that simbolize the hours of class from that day
  @@conflict_matrix = {
    "Monday"    => {},
    "Tuesday"   => {},
    "Wednesday" => {},
    "Thursday"  => {},
    "Friday"    => {},
    "Saturday"  => {},
    "Sunday"    => {}
  }

  def temporal_student
    @@temporal_student
  end

  def load(path)
    hash = FileModule.deserialize(path.split("/").last.split(".").first)
    @@temporal_student = hash[:temporal_student]
    @@rooms = hash[:rooms]
    @@students = hash[:students]
    @@conflict_matrix = hash[:conflict_matrix]
  end

  def save(path)
    package = {
      :temporal_student => @@temporal_student,
      :rooms            => @@rooms,
      :students         => @@students,
      :conflict_matrix  => @@conflict_matrix  
    }
    FileModule.web_serialize(package, "db/#{path.split("/").last}")
    return path
  end

  def initialize 
    fill_conflict_matrix() 
  end

  #return: conflict matrix structure
  def conflict_matrix
    return @@conflict_matrix
  end

  #return: true, is the conlict matrix is just initialized, no values were added
  def conflict_matrix_is_clean?
    @@conflict_matrix.each do |key,value|
      (6..20).each do |n| 
        input = @@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]
        return false if !input.eql?("0") 
      end
    end
    return true
  end

	#This method put the hours of the day in the conflict matrix 
	def fill_conflict_matrix
   @@conflict_matrix.each do |key,value|
     (6..20).each { |n| @@conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "" }
   end
  end

  #This method put 0 in the nil spaces of the the conflict_matrix
  def set_0_on_free_hours
    @@conflict_matrix.each do |key,value|
      (6..20).each do |n| 
        input = @@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]
        @@conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "0" if input.empty? || input.nil? || input.eql?("") 
      end
    end
  end

  #This method fix wrong camps of the conflict_matrix
  def fix_0_issues
    @@conflict_matrix.each do |key,value|
      (6..20).each do |n| 
        @@conflict_matrix[key]["#{n}:30 - #{n+1}:30"].tr!('0', '') 
      end
    end
  end

  #receive: a string with the correct range of hour format
  #return: the intervals of two hours to search and reserve the rooms
  def intervals_to_reserve(range)
    parts = range.split("-")
    parts[0] = Time.parse(parts[0])
    parts[1] = Time.parse(parts[1])
    intervals = []
    ####T.strftime('%l:%M %p')
    while(parts[0] < parts[1])
      interval = parts[0].strftime('%l:%M %p')
      if parts[0] + 3600*2 > parts[1]
        interval = "#{interval} -#{parts[1].strftime('%l:%M %p')}"
        parts[0] = parts[1]
      else
        parts[0] = parts[0] + 3600*2
        interval = "#{interval} -#{parts[0].strftime('%l:%M %p')}"
      end
      intervals.push(interval)
    end
    if @@students.size < intervals.size 
     puts "Cada integrante de la matriz de conflicto puede reservar 2 horas, y no hay suficientes integrantes!"
     return nil
    end
    #pp intervals
    return intervals
  end

  #receive: a string that represent a correct date format to parse
  #return: an array of strings with the ranges of hours free in the specific date of the conflict matrix
  def free_conflict_hours(date_s)
    #pp @@students
    if !@@students.any? then return nil end
    p date = what_day(Date.parse(date_s).wday)
    range_hours = []
    first = ""
    for n in 6..20 
      #p "#{n}:30 - #{n+1}:30"
      #p @@conflict_matrix[date]["#{n}:30 - #{n+1}:30"]
      if @@conflict_matrix[date]["#{n}:30 - #{n+1}:30"].eql?("0") 
        if first.eql?("")
          first = "#{n}:30 - "
        end
      elsif !first.eql?("")
        range_hours.push("#{first}#{n}:30")
        first = ""
      end
    end
    if !first.eql?("") and !first.eql?("20:30 - ")
      range_hours.push("#{first}20:30")
    end
    range_hours.map! do |range|
      demilitarize_range(range)
    end
    return range_hours
  end

  #receive: a string that represent a correct range of hour format to demilitarize
  #return: a string with the range of hour with the format 12:00 AM/PM - 0:00 AM/PM
  def demilitarize_range(range)
    parts = range.split("-")
    return "#{demilitarize_hour(parts[0])} - #{demilitarize_hour(parts[1])}"
  end

  #receive: a string that represent a correct hour format to demilitarize
  #return: a string with the range of hour with the format 12:00 AM/PM
  def demilitarize_hour(hour)
    new_hour = ""
    parts = hour.strip.split(":")
    if Integer(parts[0]) < 12 
     new_hour = "#{parts[0]}:#{parts[1]} AM" 
    elsif Integer(parts[0]) == 12
      new_hour = "#{hour} PM"
    else
      new_hour = "#{Integer(parts[0])-12}:#{parts[1]} PM"
    end
    return new_hour
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

  #return: an array of strings with the names of the rooms
  def rooms_names()
    names = []
    @@rooms.each do |room|
     names.push room.name
   end
   return names
 end

  #receive: a string the room name and a object Date
  #return: an array of strings with the schedule of a room in a specific date
  def room_schedule(room_name, date)
    room = @@rooms.find {|r| r.name == room_name}
    return room.schedule["#{date.to_s} - #{what_day(Integer(date.wday))}"]
  end

  #receive: a string or an int of the number of a month
  #return: a string with the name of the month in spanish
  def what_month_spanish(number)
    number = number.to_s
    months = {
      "1" => "Enero", 
      "2" => "Febrero",
      "3" => "Marzo", 
      "4" => "Abril", 
      "5" => "Mayo", 
      "6" => "Junio", 
      "7" => "Julio", 
      "8" => "Agosto", 
      "9" => "Septiembre", 
      "10" => "Octubre", 
      "11" => "Noviembre", 
      "12" => "Diciembre"
    }
    return months[number] 
  end

  #receive: a string or an int of the number of a month
  #return: a string with the name of the month in english
  def what_month(number)
    number = number.to_s
    months = {
      "1" => "January", 
      "2" => "February",
      "3" => "March", 
      "4" => "April", 
      "5" => "May", 
      "6" => "June", 
      "7" => "July", 
      "8" => "August", 
      "9" => "September", 
      "10" => "October", 
      "11" => "November", 
      "12" => "December"
    }
    return months[number] 
  end
end 