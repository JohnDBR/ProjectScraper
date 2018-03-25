require_relative '../modules/bot_module'
require_relative 'scraped'
require_relative 'student'
require_relative 'room'
require 'date'

class ScrapingPomelo < Scraped

  def initialize
    super
  end

  #receive: a boolean, true if we are going to add a student to the conflict matrix false if he is a temporal student 
  def student_info(save = false)
    ##get name and code of the student from the banner on top of the page
    page = BotModule.get_page(BotModule.links[:schedule])
    
    ##selecting the last semester to see the schedule
    form = page.forms[1]
    period = ""
    if Integer(Date.today.month.to_s) < 6
      period = "#{Date.today.to_s.split("-")[0]}10"
    else
      period = "#{Date.today.to_s.split("-")[0]}30"
    end
    p period
    p form.fields[0].value = period
    page = form.submit
    
    ##searching the correct tables to "scrap" the hours of class
    tables_container = page.parser.css('.datadisplaytable')
    tables_container.each do |table|
      if table.css('.captiontext').text.eql?("Horas de Reuni\u00F3n Programadas")
        table_rows = table.css('tr')
        table_rows.each do |table_row|
          table_elements = table_row.css('.dddefault')
          if table_elements.length != 0
           parts = @@temporal_student.add_to_schedule("#{table_elements[1].text} - #{table_elements[2].text}")
            if save 
              hour1 = Integer(parts[0].split(":")[0])
              hour2 = Integer(parts[1].split(":")[0])
              if hour2 == hour1 + 1
                @@conflict_matrix[parts[2]]["#{parts[0]} - #{parts[1]}"] = "#{@@conflict_matrix[parts[2]]["#{parts[0]} - #{parts[1]}"]} #{@@temporal_student.name.split(" ")[0]}" #[parts[2]].push("#{parts[0]}-#{parts[1]}-#{name.split(" ")[0]}")
              else 
                while hour1 != hour2
                  @@conflict_matrix[parts[2]]["#{hour1}:30 - #{hour1+1}:30"] = "#{@@conflict_matrix[parts[2]]["#{hour1}:30 - #{hour1+1}:30"]} #{@@temporal_student.name.split(" ")[0]}"
                  hour1 = hour1+1
                end
              end
            end 
          end
        end
      end
    end
    if save
      @@students.push(@@temporal_student)
      @@conflict_matrix.each do |key, value| 
         value.each do |key2, value2| 
          if !value2.nil? and !value2.empty?
            @@conflict_matrix[key][key2] = value2.split.uniq.join(" ")
          end
        end
      end
      BotModule.reset_entity
      set_0_on_free_hours
      fix_0_issues
      return @@conflict_matrix
    end
    BotModule.reset_entity
    return @@temporal_student.schedule
  end

end