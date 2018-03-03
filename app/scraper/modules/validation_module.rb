require 'date'
require 'time'

module ValidationModule
  
  #receive: a string to validate 
  #return: a boolean, true if the string doesn't have special characters (.^!~)
  def self.validate_non_special_characters(string)
    string = string.to_s
    if string.empty? then return false end
    char_array = string.scan(/[a-z0-9 ]/i)
    string_scaned = ""
    char_array.each {|char| string_scaned = string_scaned + char}
    return string.eql?(string_scaned)
  end
    
  #receive: a string to validate 
  #return: a boolean, true if the string is a float
  def self.validate_float(string)
    string = string.to_s
    if string.empty? then return false end
    Float(string) rescue return false
    return true
  end
    
  #receive: a string to validate 
  #return: a boolean, true if the string is a int
  def self.validate_int(string)
    string = string.to_s
    if string.empty? then return false end
    Integer(string) rescue return false
    return true
  end
    
  #receive: a string to validate 
  #return: a boolean, true if the string is a int and it's in the specified range
  def self.validate_int_range(string, min, max)
    begin
      int = Integer(string)
      min = Integer(min)
      max = Integer(max)
    rescue
      return false
    end
    if min <= int && int <= max then return true end
    return false
  end
    
  #receive: a string to validate 
  #return: a boolean, true if the string is all letters
  def self.validate_word(string)
    string = string.to_s
    if string.empty? then return false end
    char_array = string.scan(/[a-z]/i)
    string_scaned = ""
    char_array.each {|char| string_scaned = string_scaned + char}
    return string.eql?(string_scaned)
  end
    
  #receive: a string to validate 
  #return: a boolean, true if the string is all numbers (good method for big strings)
  def self.validate_number(string)
    string = string.to_s
    if string.empty? then return false end
    char_array = string.scan(/[0-9]/i)
    string_scaned = ""
    char_array.each {|char| string_scaned = string_scaned + char}
    return string.eql?(string_scaned)
  end
   
  #receive: a string to validate and the expected length
  #return: a boolean, true if the string is all numbers (good method for big strings)
  def self.validate_length(string, expected_length)
    string = string.to_s
    begin
      expected_length = Integer(expected_length)
    rescue
      puts "expected_length error!"
      return false
    end
    if string.empty? then return false end
    if string.length <= expected_length then return true end ##I just dont know what happened here!
    return false
  end
   
  #receive: a string to validate
  #return: a boolean, true if the string is all numbers and are 10
  def self.validate_cellphone(string)
    if string.empty? then return false end
    if validate_number(string) && string.length == 10 then return true end
    return false
  end
    
  #receive: a string to validate
  #return: a boolean, true if the string is all numbers and are 10
  def self.validate_email_format(string)
    string = string.to_s
    if string.empty? then return false end
    if string.include?("@") then return true end
    return false
  end 
      
  #receive: a string to validate
  #return: a boolean, true if the string have the date format: dd-MM-yyyy
  def self.validate_date_format(string)
    begin 
      fields = string.split("-")
      if fields.length != 3 then return false end
      if fields[0].length != 2  || fields[1].length != 2 || fields[2].length != 4 then return false end
      if !validate_int(fields[0]) || !validate_int(fields[1]) || !validate_int(fields[2]) then return false end
    rescue
      return false
    end
    return true
  end

  #receive: a string to validate
  #return: a boolean, true if the string is a correct date
  def self.validate_date(string)
    begin
      Date.parse(string)
      parts = []
      if string.include? "-"
        parts = string.split("-")
      elsif string.include? "/"
        parts = string.split("/")
      else
        return false
      end
      return false if parts.size > 3 or parts.size < 3
    rescue 
      return false
    end
    return true
  end 

  #receive: a string to validate
  #return: a boolean, true if the string is a correct date before today (today is include)
  def self.validate_past_date(string)
    begin
      date = Date.parse(string)
      parts = []
      if string.include? "-"
        parts = string.split("-")
      elsif string.include? "/"
        parts = string.split("/")
      else
        return false
      end
      return false if parts.size > 3 or parts.size < 3
      if date <= Date.today
        return true
      end
    rescue 
    end
    return false
  end 

  #receive: a string to validate
  #return: a boolean, true if the string is a correct date after today (today is include)
  def self.validate_future_date(string)
    begin
      date = Date.parse(string)
      parts = []
      if string.include? "-"
        parts = string.split("-")
      elsif string.include? "/"
        parts = string.split("/")
      else
        return false
      end
      return false if parts.size > 3 or parts.size < 3
      if date >= Date.today
        return true
      end
    rescue 
    end
    return false
  end 

  #receive: a string to validate
  #return: a boolean, true if the string is a correct hour
  def self.validate_hour(string)
    begin
      t = Time.parse string
      parts = string.split(":")
      identifier = string.split()
      #if t > Time.now
      #  return true
      #end
      bool = validate_int_range(parts[0], "0", "12") and validate_int_range(parts[1].split()[0], "0", "59")
      bool = false if identifier.size < 2
      if !string.downcase.include?("am") and !string.downcase.include?("pm") then bool = false end
      return bool
    rescue 
    end
    return false
  end 

  #receive: a string to validate
  #return: a boolean, true if the string is a correct range hour
  def self.validate_range_hour(string)
    begin
      parts = string.split("-")
      bool = validate_hour(parts[0]) && validate_hour(parts[1])
      range = parts[0].split
      range1 = parts[1].split
      if range[1].downcase.eql?("pm") and range1[1].downcase.eql?("am")
        bool = false
      end
      return bool
    rescue
    end
    return false
  end

  #receive: a string to validate, and the expected difference
  #return: a boolean, true if the string is a correct range hour
  def self.validate_range_hour_difference(string, difference)
    begin
      difference = Integer(difference)
      parts = string.split("-")
      bool = validate_hour(parts[0]) && validate_hour(parts[1])
      range = parts[0].split
      range1 = parts[1].split
      if range[1].downcase.eql?("pm") and range1[1].downcase.eql?("am") then bool = false end
      dif = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
      if dif < 0 then bool = false end
      if dif > difference then bool = false end
      return bool
    rescue
    end
    return false
  end

  #receive: a string to validate, the exptected difference and the bounds of the range
  #return: a boolean, true if the string is a correct range hour
  def self.validate_range_hour_starting(string, difference, stg_range)
    begin
      difference = Integer(difference)
      parts = string.split("-")
      bool = validate_hour(parts[0]) && validate_hour(parts[1])
      range = parts[0].split
      range1 = parts[1].split
      if range[1].downcase.eql?("pm") and range1[1].downcase.eql?("am") then bool = false end
      dif = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
      if dif < 0 then bool = false end
      if dif > difference then bool = false end
      stg_parts = stg_range.split("-")
      if Time.parse(stg_parts[0]) > Time.parse(parts[0]) or Time.parse(stg_parts[1]) < Time.parse(parts[1]) then bool = false end
      return bool
    rescue
    end
    return false
  end

  #receive: a string to validate, the exptected difference, the bounds of the range and the interval of the range
  #return: a boolean, true if the string is a correct range hour
  def self.validate_range_hour_interval(string, difference, stg_range, interval)
    begin
      difference = Integer(difference)
      parts = string.split("-")
      bool = validate_hour(parts[0]) && validate_hour(parts[1])
      range = parts[0].split
      range1 = parts[1].split
      if range[1].downcase.eql?("pm") and range1[1].downcase.eql?("am") then bool = false end
      dif = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
      if dif < 0 then bool = false end
      if dif > difference then bool = false end
      stg_parts = stg_range.split("-")
      if Time.parse(stg_parts[0]) > Time.parse(parts[0]) or Time.parse(stg_parts[1]) < Time.parse(parts[1]) then bool = false end
      if dif % Float(interval) != 0 then bool = false end
      return bool
    rescue
    end
    return false
  end

  #receive: a string to validate, the bounds of the range and the interval of the range
  #return: a boolean, true if the string is a correct range hour
  def self.validate_range_hour_between(string, stg_range, interval)
    begin
      parts = string.split("-")
      bool = validate_hour(parts[0]) && validate_hour(parts[1])
      range = parts[0].split
      range1 = parts[1].split
      if range[1].downcase.eql?("pm") and range1[1].downcase.eql?("am") then bool = false end
      dif = (Time.parse(parts[1]) - Time.parse(parts[0]))/3600
      if dif < 0 then bool = false end
      stg_parts = stg_range.split("-")
      if Time.parse(stg_parts[0]) > Time.parse(parts[0]) or Time.parse(stg_parts[1]) < Time.parse(parts[1]) then bool = false end
      if dif % Float(interval) != 0 then bool = false end
      return bool
    rescue
    end
    return false
  end
end